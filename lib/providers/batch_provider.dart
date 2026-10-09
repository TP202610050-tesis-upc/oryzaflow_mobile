import 'package:flutter/material.dart';
import '../core/enums/batch_status.dart';
import '../core/network/api_error.dart';
import '../core/storage/offline_cache.dart';
import '../core/sync/sync_service.dart';
import '../models/batch_model.dart';
import '../models/drying_profile_model.dart';
import '../models/manual_reading_model.dart';
import '../models/node_model.dart';
import '../models/pair_model.dart';
import '../models/pending_event_model.dart';
import '../models/segment_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/silo_model.dart';
import '../models/variety_model.dart';
import '../models/volteo_model.dart';
import '../repositories/i_batch_repository.dart';
import '../repositories/i_drying_profile_repository.dart';
import '../repositories/i_node_repository.dart';
import '../repositories/i_silo_repository.dart';
import '../repositories/i_variety_repository.dart';

/// Estado del lote tal como debe verse en pantalla: el del servidor (o la caché) con los eventos
/// registrados sin señal todavía no sincronizados aplicados encima (HU-010, CA-010-02).
class EstadoLoteVisual {
  final BatchStatus estado;
  /// true = cubierto, false = descubierto, null = desconocido.
  final bool? cubierto;
  /// El último CUBRIR/DESCUBRIR aún no sincronizado (null si no hay).
  final TipoEvento? coberturaPendiente;
  final bool recogidaPendiente;
  final int pendientes;
  final int errores;

  const EstadoLoteVisual({
    required this.estado,
    required this.cubierto,
    required this.coberturaPendiente,
    required this.recogidaPendiente,
    required this.pendientes,
    required this.errores,
  });
}

class BatchProvider extends ChangeNotifier {
  final IBatchRepository _batchRepo;
  final ISiloRepository _siloRepo;
  final IVarietyRepository _varietyRepo;
  final IDryingProfileRepository _profileRepo;
  final INodeRepository _nodeRepo;
  final OfflineCache _cache;
  final SyncService _sync;

  BatchProvider(this._batchRepo, this._siloRepo, this._varietyRepo,
      this._profileRepo, this._nodeRepo, this._cache, this._sync) {
    _sync.addListener(_onSync);
  }

  List<BatchModel> _lotes = [];
  BatchModel? _loteSeleccionado;
  List<SensorReadingModel> _lecturas = [];
  List<SiloModel> _silos = [];
  List<VarietyModel> _variedades = [];
  List<DryingProfileModel> _perfiles = [];
  List<NodeModel> _nodos = [];
  List<ManualReadingModel> _lecturasManuales = [];
  List<VolteoModel> _volteosServidor = [];
  PairsModel? _pares;
  bool _cargando = false;
  bool _cargandoLecturas = false;
  bool _cargandoPares = false;
  bool _procesando = false;
  bool _desdeCache = false;
  DateTime? _cacheGuardadoEn;
  int _pendientesPrevios = 0;
  String? _error;

  List<BatchModel> get lotes => _lotes;
  BatchModel? get loteSeleccionado => _loteSeleccionado;
  List<SensorReadingModel> get lecturas => _lecturas;
  List<SiloModel> get silos => _silos;
  List<VarietyModel> get variedades => _variedades;
  List<DryingProfileModel> get perfiles => _perfiles;
  List<NodeModel> get nodos => _nodos;
  List<ManualReadingModel> get lecturasManuales => _lecturasManuales;
  PairsModel? get pares => _pares;
  bool get estaCargando => _cargando;
  bool get estaCargandoLecturas => _cargandoLecturas;
  bool get estaCargandoPares => _cargandoPares;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  /// Los datos mostrados vienen de la caché local (sin señal) y cuándo se guardaron.
  bool get desdeCache => _desdeCache;
  DateTime? get cacheGuardadoEn => _cacheGuardadoEn;
  bool get hayRed => _sync.hayRed;

  /// Volteos del servidor más los registrados sin señal (pendientes), de más reciente a más antiguo.
  List<VolteoModel> get volteos {
    final id = _loteSeleccionado?.id;
    final locales = id == null
        ? const <VolteoModel>[]
        : _sync
            .eventosDeLote(id)
            .where((e) => e.tipo == TipoEvento.volteo && !e.terminado)
            .map(VolteoModel.local);
    final todos = [..._volteosServidor, ...locales];
    todos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return todos;
  }

  int pendientesDeLote(String id) => _sync
      .eventosDeLote(id)
      .where((e) => !e.terminado && e.estado != EstadoEvento.error)
      .length;
  int erroresDeLote(String id) =>
      _sync.eventosDeLote(id).where((e) => e.estado == EstadoEvento.error).length;

  /// Estado optimista del lote: pliega RECOGER → Completado y CUBRIR/DESCUBRIR → cubierto/descubierto.
  EstadoLoteVisual estadoVisual(BatchModel lote) {
    final pend = _sync.eventosDeLote(lote.id).where((e) => !e.terminado).toList();
    var estado = lote.estado;
    bool? cubierto = lote.segmentoAbierto == null ? null : !lote.segmentoAbierto!;
    TipoEvento? cobertura;
    var recogida = false;
    for (final e in pend) {
      switch (e.tipo) {
        case TipoEvento.recoger:
          estado = BatchStatus.completado;
          recogida = true;
        case TipoEvento.cubrir:
          cubierto = true;
          cobertura = TipoEvento.cubrir;
        case TipoEvento.descubrir:
          cubierto = false;
          cobertura = TipoEvento.descubrir;
        case TipoEvento.volteo:
          break;
      }
    }
    return EstadoLoteVisual(
      estado: estado,
      cubierto: cubierto,
      coberturaPendiente: cobertura,
      recogidaPendiente: recogida,
      pendientes: pend.where((e) => e.estado != EstadoEvento.error).length,
      errores: pend.where((e) => e.estado == EstadoEvento.error).length,
    );
  }

  BatchStatus estadoVisualDe(BatchModel lote) => estadoVisual(lote).estado;

  List<BatchModel> get lotesActivos =>
      _lotes.where((l) => estadoVisualDe(l) == BatchStatus.enProceso).toList();
  List<BatchModel> get lotesHistorial =>
      _lotes.where((l) => estadoVisualDe(l) != BatchStatus.enProceso).toList();

  Future<void> cargarLotes() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _lotes = List.of(await _batchRepo.obtenerLotes());
      _marcarOnline();
    } catch (e) {
      final c = _esRecuperable(e) ? await _cache.leerLotes() : null;
      if (c != null) {
        _lotes = c.data
            .whereType<Map<String, dynamic>>()
            .map(BatchModel.fromJson)
            .toList();
        _marcarDesdeCache(c.guardadoEn);
      } else {
        _error = apiErrorMessage(e);
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarLote(String id) async {
    _cargando = true;
    notifyListeners();
    try {
      _loteSeleccionado = await _batchRepo.obtenerLotePorId(id);
      _marcarOnline();
    } catch (e) {
      final c = _esRecuperable(e) ? await _cache.leerLote(id) : null;
      if (c != null) {
        _loteSeleccionado = BatchModel.fromJson(c.data);
        _marcarDesdeCache(c.guardadoEn);
      } else {
        _error = apiErrorMessage(e);
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Refresca solo el lote (estimación, marca "por verificar", alertas) sin pasar por el estado de carga.
  Future<void> refrescarLote(String id) async {
    try {
      _loteSeleccionado = await _batchRepo.obtenerLotePorId(id);
      _actualizarLoteEnLista(_loteSeleccionado!);
      _marcarOnline();
      notifyListeners();
    } catch (_) {}
  }

  /// Lecturas para las gráficas del lote: todo su periodo (inicio → cierre, o → ahora si sigue en proceso),
  /// no una ventana relativa a «ahora»; así un lote cerrado conserva su curva. El backend recorta la ventana
  /// a [fechaInicio, fechaFin] del lote.
  Future<void> cargarLecturas(String loteId) async {
    _cargandoLecturas = true;
    notifyListeners();
    try {
      final lote = _loteSeleccionado?.id == loteId
          ? _loteSeleccionado!
          : await _batchRepo.obtenerLotePorId(loteId);
      final hasta = lote.fechaFin ?? DateTime.now();
      final desde = lote.fechaInicio ?? lote.fechaIngreso;
      _lecturas = await _batchRepo.obtenerLecturasLote(loteId,
          desde: desde, hasta: hasta);
    } catch (e) {
      // Sin señal con lote cacheado: las gráficas quedan vacías, sin estado de error.
      if (!(_desdeCache && _esRecuperable(e))) _error = apiErrorMessage(e);
    } finally {
      _cargandoLecturas = false;
      notifyListeners();
    }
  }

  /// Volteos del lote con su hora original (GET /flips); sin señal, los de la caché.
  Future<void> cargarVolteos(String loteId) async {
    try {
      _volteosServidor = await _batchRepo.listarVolteos(loteId);
    } catch (e) {
      final c = _esRecuperable(e) ? await _cache.leerVolteos(loteId) : null;
      if (c != null) {
        _volteosServidor = c.data
            .whereType<Map<String, dynamic>>()
            .map(VolteoModel.fromJson)
            .toList();
      }
    }
    notifyListeners();
  }

  Future<void> cargarFormularioNuevoLote() async {
    _cargando = true;
    notifyListeners();
    try {
      final r = await Future.wait([
        _siloRepo.obtenerSilos(),
        _varietyRepo.obtenerVariedades(),
        _profileRepo.obtenerPerfiles(),
        _nodeRepo.obtenerNodos(),
      ]);
      _silos = r[0] as List<SiloModel>;
      _variedades = r[1] as List<VarietyModel>;
      _perfiles = r[2] as List<DryingProfileModel>;
      _nodos = r[3] as List<NodeModel>;
    } catch (e) {
      _error = apiErrorMessage(e);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<BatchModel?> crearLote(BatchModel lote) async {
    _procesando = true;
    notifyListeners();
    try {
      final nuevo = await _batchRepo.crearLote(lote);
      _lotes.insert(0, nuevo);
      notifyListeners();
      return nuevo;
    } catch (e) {
      _error = apiErrorMessage(e);
      return null;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  /// Iniciar el secado requiere conexión (aprovisiona el nodo); no se encola.
  Future<bool> iniciarSecado(String id) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _batchRepo.iniciarSecado(id);
      _actualizarLoteEnLista(updated);
      if (_loteSeleccionado?.id == id) _loteSeleccionado = updated;
      return true;
    } catch (e) {
      _error = apiErrorMessage(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ---- Eventos del lote (HU-010, CA-010-02): se envían o se encolan con su hora ----

  /// Registra un volteo manual del lote (#45).
  Future<ResultadoRegistro> registrarVolteo(String loteId) =>
      _registrar(TipoEvento.volteo, loteId, const {'metodo': 'MANUAL'});

  /// Cubrir: cierra el tramo de secado (NOCHE / LLUVIA).
  Future<ResultadoRegistro> cubrirLote(String loteId, MotivoCierre motivo) =>
      _registrar(TipoEvento.cubrir, loteId, {'motivo': motivo.api});

  /// Descubrir: abre el tramo siguiente con la M0 del PM-410.
  Future<ResultadoRegistro> descubrirLote(String loteId, double m0) =>
      _registrar(TipoEvento.descubrir, loteId, {'m0': m0});

  /// Recoger: detiene el secado; humedad final del PM-410 opcional.
  Future<ResultadoRegistro> detenerSecado(String loteId, {double? humedadFinal}) =>
      _registrar(TipoEvento.recoger, loteId,
          {if (humedadFinal != null) 'humedadFinal': humedadFinal});

  Future<ResultadoRegistro> _registrar(
      TipoEvento tipo, String loteId, Map<String, dynamic> payload) async {
    final lote = _loteSeleccionado?.id == loteId
        ? _loteSeleccionado!
        : _lotes.firstWhere((l) => l.id == loteId);
    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _sync.registrar(PendingEvent.nuevo(
        tipo: tipo,
        lote: lote,
        ts: DateTime.now().toUtc(),
        payload: payload,
        usuarioEmail: _sync.usuarioActualEmail(),
      ));
      if (r is Rechazado) _error = r.mensaje;
      if (r is Enviado) {
        await refrescarLote(loteId);
        await cargarVolteos(loteId);
      }
      return r;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ---- Lecturas manuales del medidor y pares (HU-013, CA-013-01/02) ----

  Future<void> cargarPares(String loteId) async {
    _cargandoPares = true;
    notifyListeners();
    try {
      final r = await Future.wait([
        _batchRepo.obtenerPares(loteId),
        _batchRepo.obtenerLecturasManuales(loteId),
      ]);
      _pares = r[0] as PairsModel;
      _lecturasManuales = r[1] as List<ManualReadingModel>;
    } catch (e) {
      _error = apiErrorMessage(e);
    } finally {
      _cargandoPares = false;
      notifyListeners();
    }
  }

  /// Registra la lectura del PM-410 y recarga pares y lote (la marca "por verificar" la decide el backend).
  Future<ManualReadingModel?> registrarLecturaManual(
      String loteId, ManualReadingDraft lectura) async {
    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      final creada = await _batchRepo.registrarLecturaManual(loteId, lectura);
      await cargarPares(loteId);
      await refrescarLote(loteId);
      return creada;
    } catch (e) {
      _error = apiErrorMessage(e);
      return null;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ---- internos ----

  bool _esRecuperable(Object e) => esErrorDeRed(e) || esErrorServidor(e);

  void _marcarOnline() {
    _desdeCache = false;
    _cacheGuardadoEn = null;
  }

  void _marcarDesdeCache(DateTime guardadoEn) {
    _desdeCache = true;
    _cacheGuardadoEn = guardadoEn;
    _error = null;
  }

  /// Cambios en la cola: repintar y, cuando el lote abierto termina de sincronizar, recargarlo
  /// para mostrar las horas originales que devuelve el servidor.
  void _onSync() {
    final id = _loteSeleccionado?.id;
    final ahora = id == null ? 0 : pendientesDeLote(id);
    if (id != null && _pendientesPrevios > 0 && ahora == 0 && _sync.hayRed) {
      refrescarLote(id);
      cargarVolteos(id);
    }
    _pendientesPrevios = ahora;
    notifyListeners();
  }

  void _actualizarLoteEnLista(BatchModel updated) {
    final idx = _lotes.indexWhere((l) => l.id == updated.id);
    if (idx != -1) _lotes[idx] = updated;
  }

  @override
  void dispose() {
    _sync.removeListener(_onSync);
    super.dispose();
  }
}
