import 'dart:collection';

import 'package:oryzaflow_mobile/core/enums/batch_status.dart';
import 'package:oryzaflow_mobile/models/batch_model.dart';
import 'package:oryzaflow_mobile/models/manual_reading_model.dart';
import 'package:oryzaflow_mobile/models/pair_model.dart';
import 'package:oryzaflow_mobile/models/segment_model.dart';
import 'package:oryzaflow_mobile/models/sensor_reading_model.dart';
import 'package:oryzaflow_mobile/models/volteo_model.dart';
import 'package:oryzaflow_mobile/repositories/i_batch_repository.dart';

/// Llamada registrada por el repositorio falso.
class LlamadaFake {
  final String metodo;
  final String loteId;
  final DateTime? ts;
  final String? clientEventId;
  final Map<String, dynamic> extra;
  const LlamadaFake(this.metodo, this.loteId, {this.ts, this.clientEventId, this.extra = const {}});

  @override
  String toString() => '$metodo($loteId, ts=$ts, id=$clientEventId, $extra)';
}

/// IBatchRepository de prueba: registra las llamadas de eventos y responde con lo que se le
/// programe en `respuestas` (un valor → se devuelve; una excepción → se lanza; vacío → valor por defecto).
class FakeBatchRepository implements IBatchRepository {
  final List<LlamadaFake> llamadas = [];
  final Queue<Object?> respuestas = Queue();

  BatchModel lotePorDefecto(String id) => BatchModel(
        id: id,
        codigo: 'LOTE-$id',
        siloId: '1',
        siloNombre: 'Explanada',
        variedadId: '1',
        variedadNombre: 'Casserita',
        perfilSecadoId: '1',
        perfilSecadoNombre: 'Perfil',
        nodoId: '1',
        nodoNombre: 'Nodo',
        estado: BatchStatus.enProceso,
        pesoKg: 320,
        humedadInicial: 15,
        fechaIngreso: DateTime.utc(2026, 10, 9, 12),
        operadorId: '1',
        operadorNombre: 'Operador',
      );

  T _responder<T>(T Function() porDefecto) {
    if (respuestas.isEmpty) return porDefecto();
    final r = respuestas.removeFirst();
    if (r == null) return porDefecto();
    if (r is Exception || r is Error) throw r;
    return r as T;
  }

  @override
  Future<VolteoModel> registrarVolteo(String loteId,
      {DateTime? timestamp, String? clientEventId}) async {
    llamadas.add(LlamadaFake('registrarVolteo', loteId, ts: timestamp, clientEventId: clientEventId));
    return _responder(() => VolteoModel(
          id: '${llamadas.length}',
          loteId: loteId,
          metodo: MetodoVolteo.manual,
          timestamp: (timestamp ?? DateTime.now()).toLocal(),
        ));
  }

  @override
  Future<BatchModel> detenerSecado(String id,
      {DateTime? fechaFin, double? humedadFinal, String? clientEventId}) async {
    llamadas.add(LlamadaFake('detenerSecado', id,
        ts: fechaFin, clientEventId: clientEventId, extra: {'humedadFinal': humedadFinal}));
    return _responder(() => lotePorDefecto(id)
        .copyWith(estado: BatchStatus.completado, fechaFin: fechaFin, humedadFinal: humedadFinal));
  }

  @override
  Future<SegmentModel> cerrarSegmento(String loteId,
      {required DateTime finTs,
      required MotivoCierre motivo,
      double? humedadFinal,
      String? clientEventId}) async {
    llamadas.add(LlamadaFake('cerrarSegmento', loteId,
        ts: finTs, clientEventId: clientEventId, extra: {'motivo': motivo.api}));
    return _responder(() => SegmentModel(
        id: '1', loteId: loteId, numero: 1, inicioTs: finTs, finTs: finTs, motivoCierre: motivo.api));
  }

  @override
  Future<SegmentModel> abrirSegmento(String loteId,
      {required double m0, required DateTime inicioTs, String? clientEventId}) async {
    llamadas.add(LlamadaFake('abrirSegmento', loteId,
        ts: inicioTs, clientEventId: clientEventId, extra: {'m0': m0}));
    return _responder(() =>
        SegmentModel(id: '2', loteId: loteId, numero: 2, inicioTs: inicioTs, m0: m0, abierto: true));
  }

  @override
  Future<List<VolteoModel>> listarVolteos(String loteId) async {
    llamadas.add(LlamadaFake('listarVolteos', loteId));
    return _responder(() => <VolteoModel>[]);
  }

  @override
  Future<BatchModel> obtenerLotePorId(String id) async {
    llamadas.add(LlamadaFake('obtenerLotePorId', id));
    return _responder(() => lotePorDefecto(id));
  }

  @override
  Future<List<BatchModel>> obtenerLotes() async {
    llamadas.add(const LlamadaFake('obtenerLotes', '-'));
    return _responder(() => <BatchModel>[]);
  }

  // ── no usados por la cola ──
  @override
  Future<List<BatchModel>> obtenerLotesActivos() => throw UnimplementedError();
  @override
  Future<BatchModel> crearLote(BatchModel lote) => throw UnimplementedError();
  @override
  Future<BatchModel> actualizarEstado(String id, BatchStatus nuevoEstado) =>
      throw UnimplementedError();
  @override
  Future<BatchModel> iniciarSecado(String id) => throw UnimplementedError();
  @override
  Future<List<SensorReadingModel>> obtenerLecturasLote(String loteId,
          {required DateTime desde, required DateTime hasta}) =>
      throw UnimplementedError();
  @override
  Future<ManualReadingModel> registrarLecturaManual(String loteId, ManualReadingDraft lectura) =>
      throw UnimplementedError();
  @override
  Future<List<ManualReadingModel>> obtenerLecturasManuales(String loteId) =>
      throw UnimplementedError();
  @override
  Future<PairsModel> obtenerPares(String loteId) => throw UnimplementedError();
}
