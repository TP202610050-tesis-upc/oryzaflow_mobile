import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/core/sync/event_queue_store.dart';
import 'package:oryzaflow_mobile/core/sync/sync_service.dart';
import 'package:oryzaflow_mobile/models/pending_event_model.dart';

import '../../fakes/fake_batch_repository.dart';
import '../../fakes/fake_connectivity_probe.dart';
import '../../fakes/in_memory_local_store.dart';

DioException _red() => DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: DioExceptionType.connectionError);

DioException _http(int code, String mensaje) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.badResponse,
      response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: code,
          data: {'message': mensaje}),
    );

void main() {
  late InMemoryLocalStore store;
  late EventQueueStore cola;
  late FakeBatchRepository repo;
  late FakeConnectivityProbe probe;
  late SyncService sync;
  var reloj = DateTime.utc(2026, 10, 9, 18, 0);

  PendingEvent ev(TipoEvento tipo, {String lote = '9', int min = 0, String? email}) =>
      PendingEvent.nuevo(
        tipo: tipo,
        lote: repo.lotePorDefecto(lote),
        ts: DateTime.utc(2026, 10, 9, 13, 5 + min, 12),
        payload: switch (tipo) {
          TipoEvento.volteo => {'metodo': 'MANUAL'},
          TipoEvento.cubrir => {'motivo': 'NOCHE'},
          TipoEvento.descubrir => {'m0': 22.5},
          TipoEvento.recoger => {'humedadFinal': 13.8},
        },
        usuarioEmail: email,
      );

  Future<SyncService> crear({bool red = true}) async {
    probe = FakeConnectivityProbe(red: red);
    sync = SyncService(cola, repo, probe,
        ahora: () => reloj, periodo: const Duration(hours: 1));
    await sync.init();
    return sync;
  }

  Future<void> asentar() => Future<void>.delayed(const Duration(milliseconds: 30));

  setUp(() {
    store = InMemoryLocalStore();
    cola = EventQueueStore(store);
    repo = FakeBatchRepository();
    reloj = DateTime.utc(2026, 10, 9, 18, 0);
  });

  tearDown(() async {
    sync.dispose();
    await probe.cerrar();
  });

  test('1. sin red: registrar encola, no llama al backend y persiste PENDIENTE', () async {
    await crear(red: false);
    final r = await sync.registrar(ev(TipoEvento.volteo));
    expect(r, isA<Encolado>());
    expect(repo.llamadas, isEmpty);
    final guardados = await cola.cargar();
    expect(guardados.single.estado, EstadoEvento.pendiente);
    expect(sync.pendientes, 1);
  });

  test('2. con red: envía con clientEventId y ts originales; la cola queda vacía', () async {
    await crear();
    final e = ev(TipoEvento.volteo);
    final r = await sync.registrar(e);
    expect(r, isA<Enviado>());
    expect(repo.llamadas.single.metodo, 'registrarVolteo');
    expect(repo.llamadas.single.clientEventId, e.id);
    expect(repo.llamadas.single.ts, e.ts);
    expect(sync.eventos, isEmpty);
  });

  test('3. con red pero el POST falla por red: encola', () async {
    await crear();
    repo.respuestas.add(_red());
    final r = await sync.registrar(ev(TipoEvento.cubrir));
    expect(r, isA<Encolado>());
    expect(sync.pendientes, 1);
  });

  test('4. el backend rechaza (409): Rechazado con el mensaje y no se encola', () async {
    await crear();
    repo.respuestas.add(_http(409, 'Lote cerrado'));
    final r = await sync.registrar(ev(TipoEvento.recoger));
    expect(r, isA<Rechazado>());
    expect((r as Rechazado).mensaje, 'Lote cerrado');
    expect(sync.eventos, isEmpty);
  });

  test('5. con red, si el lote ya tiene pendientes el nuevo evento va detrás (orden FIFO)', () async {
    await crear(red: false);
    final e1 = ev(TipoEvento.volteo);
    await sync.registrar(e1);
    repo.respuestas.add(_red()); // el drenado por reconexión falla: e1 sigue pendiente
    probe.emitir(true);
    await asentar();
    expect(sync.eventos.single.estado, EstadoEvento.pendiente);

    final e2 = ev(TipoEvento.cubrir, min: 10);
    final r = await sync.registrar(e2);
    expect(r, isA<Encolado>());
    await asentar();
    // El drenado posterior envía e1 y luego e2.
    final enviados = repo.llamadas.where((l) => l.clientEventId != null).map((l) => l.clientEventId);
    expect(enviados.toList(), [e1.id, e1.id, e2.id]);
  });

  test('6. drena tres eventos del mismo lote en orden y avisa cuántos sincronizó', () async {
    await crear(red: false);
    final es = [ev(TipoEvento.volteo), ev(TipoEvento.cubrir, min: 1), ev(TipoEvento.descubrir, min: 2)];
    for (final e in es) {
      await sync.registrar(e);
    }
    final aviso = sync.sincronizados.first;
    probe.emitir(true);
    await asentar();
    expect(repo.llamadas.map((l) => l.metodo).toList(),
        ['registrarVolteo', 'cerrarSegmento', 'abrirSegmento']);
    expect(sync.eventos.every((e) => e.estado == EstadoEvento.sincronizado), isTrue);
    expect(sync.eventos.every((e) => e.sincronizadoEn != null), isTrue);
    expect(await aviso, 3);
  });

  test('7. un fallo de red a mitad del drenado corta y deja el resto pendiente', () async {
    await crear(red: false);
    for (var i = 0; i < 3; i++) {
      await sync.registrar(ev(TipoEvento.volteo, min: i));
    }
    repo.respuestas.addAll([null, _red()]);
    final aviso = sync.sincronizados.first;
    probe.emitir(true);
    await asentar();
    final est = sync.eventos.map((e) => e.estado).toList();
    expect(est, [EstadoEvento.sincronizado, EstadoEvento.pendiente, EstadoEvento.pendiente]);
    expect(sync.eventos[1].intentos, 1);
    expect(sync.eventos[2].intentos, 0);
    expect(await aviso, 1);
  });

  test('8. un 409 marca ERROR y bloquea los siguientes del mismo lote; otro lote sigue', () async {
    await crear(red: false);
    final a1 = ev(TipoEvento.cubrir, lote: 'A');
    final a2 = ev(TipoEvento.descubrir, lote: 'A', min: 1);
    final b1 = ev(TipoEvento.volteo, lote: 'B');
    for (final e in [a1, a2, b1]) {
      await sync.registrar(e);
    }
    repo.respuestas.add(_http(409, 'El lote no tiene un segmento abierto'));
    probe.emitir(true);
    await asentar();
    expect(sync.eventos[0].estado, EstadoEvento.error);
    expect(sync.eventos[0].ultimoError, 'El lote no tiene un segmento abierto');
    expect(sync.eventos[1].estado, EstadoEvento.pendiente);
    expect(sync.eventos[2].estado, EstadoEvento.sincronizado);
    expect(repo.llamadas.map((l) => l.clientEventId).toList(), [a1.id, b1.id]);
    expect(sync.conError, 1);

    // 9. reintentar: A1 y luego A2, en orden.
    repo.llamadas.clear();
    await sync.reintentar(a1.id);
    expect(repo.llamadas.map((l) => l.clientEventId).toList(), [a1.id, a2.id]);
    expect(sync.eventos.every((e) => e.estado == EstadoEvento.sincronizado), isTrue);
  });

  test('10. descartar elimina el evento y persiste', () async {
    await crear(red: false);
    final e = ev(TipoEvento.volteo);
    await sync.registrar(e);
    await sync.descartar(e.id);
    expect(sync.eventos, isEmpty);
    expect(await cola.cargar(), isEmpty);
  });

  test('11. dos sincronizar() concurrentes no duplican envíos', () async {
    await cola.guardar([ev(TipoEvento.volteo), ev(TipoEvento.volteo, min: 1)]);
    await crear();
    await Future.wait([sync.sincronizar(), sync.sincronizar()]);
    expect(repo.llamadas.length, 2);
    expect(sync.eventos.every((e) => e.estado == EstadoEvento.sincronizado), isTrue);
  });

  test('12. init() devuelve a PENDIENTE lo que quedó ENVIANDO', () async {
    await cola.guardar([ev(TipoEvento.volteo).copyWith(estado: EstadoEvento.enviando)]);
    await crear(red: false);
    expect(sync.eventos.single.estado, EstadoEvento.pendiente);
  });

  test('13. purga los sincronizados con más de 24 h', () async {
    final viejo = ev(TipoEvento.volteo).copyWith(
        estado: EstadoEvento.sincronizado,
        sincronizadoEn: reloj.subtract(const Duration(hours: 25)));
    final reciente = ev(TipoEvento.volteo, min: 1).copyWith(
        estado: EstadoEvento.sincronizado,
        sincronizadoEn: reloj.subtract(const Duration(hours: 23)));
    await cola.guardar([viejo, reciente]);
    await crear(red: false);
    expect(sync.eventos.map((e) => e.id).toList(), [reciente.id]);
  });

  test('14. al recuperar la red se drena solo', () async {
    await crear(red: false);
    await sync.registrar(ev(TipoEvento.recoger));
    probe.emitir(true);
    await asentar();
    expect(sync.eventos.single.estado, EstadoEvento.sincronizado);
    expect(repo.llamadas.single.metodo, 'detenerSecado');
    expect(repo.llamadas.single.extra['humedadFinal'], 13.8);
  });

  test('15. sin sesión no drena; un 401 durante el drenado corta y deja PENDIENTE', () async {
    await cola.guardar([ev(TipoEvento.volteo)]);
    await crear();
    sync.estaAutenticado = () => false;
    await sync.sincronizar();
    expect(repo.llamadas, isEmpty);

    sync.estaAutenticado = () => true;
    repo.respuestas.add(_http(401, 'Sesión expirada'));
    await sync.sincronizar();
    expect(sync.eventos.single.estado, EstadoEvento.pendiente);
    expect(sync.eventos.single.intentos, 1);
  });

  test('16. los eventos de otro usuario se conservan sin enviar', () async {
    await cola.guardar([
      ev(TipoEvento.volteo, email: 'otro@oryzaflow.pe'),
      ev(TipoEvento.volteo, min: 1, email: 'yo@oryzaflow.pe'),
    ]);
    await crear();
    sync.usuarioActualEmail = () => 'yo@oryzaflow.pe';
    await sync.sincronizar();
    expect(sync.eventos[0].estado, EstadoEvento.pendiente);
    expect(sync.eventos[1].estado, EstadoEvento.sincronizado);
    expect(repo.llamadas.length, 1);
  });
}
