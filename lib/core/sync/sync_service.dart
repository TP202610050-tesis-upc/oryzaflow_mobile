import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/pending_event_model.dart';
import '../../models/segment_model.dart';
import '../../repositories/i_batch_repository.dart';
import '../network/api_error.dart';
import 'connectivity_probe.dart';
import 'event_queue_store.dart';

/// Resultado de registrar un evento del lote.
sealed class ResultadoRegistro {
  const ResultadoRegistro();
}

/// Se envió al backend en el momento.
class Enviado extends ResultadoRegistro {
  final DateTime ts;
  const Enviado(this.ts);
}

/// Quedó guardado localmente (sin señal, fallo de red o el lote ya tenía eventos en cola).
class Encolado extends ResultadoRegistro {
  final PendingEvent evento;
  const Encolado(this.evento);
}

/// El backend lo rechazó (4xx): se muestra el mensaje y no se guarda.
class Rechazado extends ResultadoRegistro {
  final String mensaje;
  const Rechazado(this.mensaje);
}

/// Cola de eventos del lote y su sincronización (HU-010, CA-010-02; HU-49/HU-50).
///
/// - `registrar`: envía "online primero"; si no hay red, falla la red o el lote ya tiene eventos
///   pendientes (orden FIFO por lote), el evento se guarda con su hora original.
/// - `sincronizar`: drena la cola en orden. Un fallo de red corta el drenado (se reintenta con el
///   timer, al cambiar la conectividad, al volver la app o a mano); un rechazo del backend (4xx)
///   marca el evento como ERROR y bloquea los siguientes del mismo lote hasta reintentar o descartar.
/// - Cada envío lleva `clientEventId` (UUID): reenviar es seguro.
class SyncService extends ChangeNotifier {
  final EventQueueStore _store;
  final IBatchRepository _repo;
  final ConnectivityProbe _probe;
  final DateTime Function() _ahora;
  final Duration _periodo;
  final Duration _retencion;

  SyncService(
    this._store,
    this._repo,
    this._probe, {
    DateTime Function()? ahora,
    Duration periodo = const Duration(seconds: 30),
    Duration retencion = const Duration(hours: 24),
  })  : _ahora = ahora ?? DateTime.now,
        _periodo = periodo,
        _retencion = retencion;

  /// Ganchos que fija `main` (evitan acoplar el servicio al AuthProvider).
  bool Function() estaAutenticado = () => true;
  String? Function() usuarioActualEmail = () => null;

  List<PendingEvent> _eventos = [];
  bool _drenando = false;
  bool _reDrenar = false;
  bool _hayRed = true;
  bool _inicializado = false;
  Timer? _timer;
  StreamSubscription<bool>? _subRed;
  final _sincronizados = StreamController<int>.broadcast();

  List<PendingEvent> get eventos => List.unmodifiable(_eventos);
  Iterable<PendingEvent> eventosDeLote(String loteId) =>
      _eventos.where((e) => e.loteId == loteId);
  int get pendientes => _eventos
      .where((e) =>
          e.estado == EstadoEvento.pendiente || e.estado == EstadoEvento.enviando)
      .length;
  int get conError =>
      _eventos.where((e) => e.estado == EstadoEvento.error).length;
  bool get sincronizando => _drenando;
  bool get hayRed => _hayRed;
  bool get inicializado => _inicializado;

  /// Emite cuántos eventos se sincronizaron al terminar cada drenado con éxito (≥ 1).
  Stream<int> get sincronizados => _sincronizados.stream;

  Future<void> init() async {
    _eventos = await _store.cargar();
    // La app pudo morir a mitad de un envío: reenviar es seguro (clientEventId).
    _eventos = [
      for (final e in _eventos)
        e.estado == EstadoEvento.enviando
            ? e.copyWith(estado: EstadoEvento.pendiente)
            : e
    ];
    _purgar();
    await _persistir();
    _hayRed = await _probe.hayRed();
    _subRed = _probe.cambios.listen((ok) {
      _hayRed = ok;
      notifyListeners();
      if (ok) unawaited(sincronizar());
    });
    _inicializado = true;
    _programarTimer();
    notifyListeners();
  }

  /// Registra un evento. Nunca lanza.
  Future<ResultadoRegistro> registrar(PendingEvent ev) async {
    if (!_hayRed || _tieneBloqueoDeOrden(ev.loteId)) {
      final enc = await _encolar(ev);
      if (_hayRed) unawaited(sincronizar());
      return enc;
    }
    try {
      await _enviar(ev);
      return Enviado(ev.ts);
    } on DioException catch (e) {
      if (esErrorDeRed(e) || esErrorServidor(e)) return _encolar(ev);
      return Rechazado(apiErrorMessage(e));
    } catch (e) {
      return Rechazado(apiErrorMessage(e));
    }
  }

  /// Drena la cola en orden FIFO. Reentrante: si ya está drenando, marca para repetir al terminar.
  Future<void> sincronizar() async {
    if (_drenando) {
      _reDrenar = true;
      return;
    }
    if (!_hayRed || !estaAutenticado()) {
      _programarTimer();
      return;
    }
    _drenando = true;
    notifyListeners();
    var ok = 0;
    try {
      do {
        _reDrenar = false;
        final bloqueados = <String>{
          for (final e in _eventos)
            if (e.estado == EstadoEvento.error) e.loteId
        };
        final actual = usuarioActualEmail();
        for (final id in _eventos.map((e) => e.id).toList()) {
          final i = _indice(id);
          if (i == -1) continue; // descartado mientras drenábamos
          final e = _eventos[i];
          if (e.estado != EstadoEvento.pendiente) continue;
          if (bloqueados.contains(e.loteId)) continue;
          if (e.usuarioEmail != null && actual != null && e.usuarioEmail != actual) {
            continue; // evento de otro usuario: se conserva hasta que él inicie sesión
          }
          _eventos[i] = e.copyWith(estado: EstadoEvento.enviando);
          await _persistir();
          notifyListeners();
          try {
            await _enviar(e);
            _reemplazar(
                id,
                e.copyWith(
                  estado: EstadoEvento.sincronizado,
                  sincronizadoEn: _ahora().toUtc(),
                  intentos: e.intentos + 1,
                  limpiarError: true,
                ));
            ok++;
          } on DioException catch (err) {
            if (esErrorDeRed(err) ||
                esErrorServidor(err) ||
                err.response?.statusCode == 401) {
              _reemplazar(
                  id,
                  e.copyWith(
                    estado: EstadoEvento.pendiente,
                    intentos: e.intentos + 1,
                    ultimoError: apiErrorMessage(err),
                  ));
              await _persistir();
              notifyListeners();
              return; // sin red: se corta y se reintenta después
            }
            _reemplazar(
                id,
                e.copyWith(
                  estado: EstadoEvento.error,
                  intentos: e.intentos + 1,
                  ultimoError: apiErrorMessage(err),
                ));
            bloqueados.add(e.loteId);
          } catch (err) {
            _reemplazar(
                id,
                e.copyWith(
                  estado: EstadoEvento.error,
                  intentos: e.intentos + 1,
                  ultimoError: apiErrorMessage(err),
                ));
            bloqueados.add(e.loteId);
          }
          await _persistir();
          notifyListeners();
        }
      } while (_reDrenar);
    } finally {
      _drenando = false;
      _purgar();
      await _persistir();
      _programarTimer();
      notifyListeners();
      if (ok > 0 && !_sincronizados.isClosed) _sincronizados.add(ok);
    }
  }

  Future<void> reintentar(String id) async {
    final i = _indice(id);
    if (i == -1) return;
    _eventos[i] = _eventos[i].copyWith(
        estado: EstadoEvento.pendiente, limpiarError: true);
    await _persistir();
    notifyListeners();
    await sincronizar();
  }

  Future<void> descartar(String id) async {
    _eventos.removeWhere((e) => e.id == id);
    await _persistir();
    _programarTimer();
    notifyListeners();
  }

  // ── internos ──

  Future<void> _enviar(PendingEvent e) => switch (e.tipo) {
        TipoEvento.volteo =>
          _repo.registrarVolteo(e.loteId, timestamp: e.ts, clientEventId: e.id),
        TipoEvento.cubrir => _repo.cerrarSegmento(
            e.loteId,
            finTs: e.ts,
            motivo: motivoCierreFromApi(e.payload['motivo'] as String?),
            humedadFinal: (e.payload['humedadFinal'] as num?)?.toDouble(),
            clientEventId: e.id,
          ),
        TipoEvento.descubrir => _repo.abrirSegmento(
            e.loteId,
            m0: (e.payload['m0'] as num).toDouble(),
            inicioTs: e.ts,
            clientEventId: e.id,
          ),
        TipoEvento.recoger => _repo.detenerSecado(
            e.loteId,
            fechaFin: e.ts,
            humedadFinal: (e.payload['humedadFinal'] as num?)?.toDouble(),
            clientEventId: e.id,
          ),
      };

  Future<Encolado> _encolar(PendingEvent ev) async {
    final guardado = ev.copyWith(estado: EstadoEvento.pendiente);
    _eventos.add(guardado);
    await _persistir();
    _programarTimer();
    notifyListeners();
    return Encolado(guardado);
  }

  /// El lote ya tiene eventos sin sincronizar: el nuevo va detrás para respetar el orden.
  bool _tieneBloqueoDeOrden(String loteId) =>
      _eventos.any((e) => e.loteId == loteId && !e.terminado);

  void _purgar() {
    final limite = _ahora().toUtc().subtract(_retencion);
    _eventos.removeWhere((e) =>
        e.estado == EstadoEvento.sincronizado &&
        e.sincronizadoEn != null &&
        e.sincronizadoEn!.isBefore(limite));
  }

  void _programarTimer() {
    _timer?.cancel();
    _timer = null;
    if (_eventos.any((e) => e.estado == EstadoEvento.pendiente)) {
      _timer = Timer(_periodo, () => unawaited(sincronizar()));
    }
  }

  int _indice(String id) => _eventos.indexWhere((e) => e.id == id);

  void _reemplazar(String id, PendingEvent nuevo) {
    final i = _indice(id);
    if (i != -1) _eventos[i] = nuevo;
  }

  Future<void> _persistir() => _store.guardar(_eventos);

  @override
  void dispose() {
    _timer?.cancel();
    _subRed?.cancel();
    _sincronizados.close();
    super.dispose();
  }
}
