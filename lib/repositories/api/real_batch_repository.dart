import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json_mappers.dart';
import '../../core/enums/batch_status.dart';
import '../../core/storage/offline_cache.dart';
import '../../models/batch_model.dart';
import '../../models/manual_reading_model.dart';
import '../../models/pair_model.dart';
import '../../models/segment_model.dart';
import '../../models/sensor_reading_model.dart';
import '../../models/volteo_model.dart';
import '../i_batch_repository.dart';

/// Lotes de secado reales (BC4): ciclo de vida, lecturas de telemetría y lecturas manuales del medidor.
/// Los GET de lotes y volteos se guardan en la caché local (HU-010, CA-010-02) para abrir la app sin señal.
class RealBatchRepository implements IBatchRepository {
  final ApiClient _api;
  final OfflineCache _cache;

  RealBatchRepository(this._api, this._cache);

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  /// Un fallo al escribir la caché nunca rompe un GET exitoso.
  Future<void> _cachear(Future<void> Function() escribir) async {
    try {
      await escribir();
    } catch (e) {
      debugPrint('OfflineCache: no se pudo guardar ($e)');
    }
  }

  List<BatchModel> _parseLotes(dynamic data) => (data as List<dynamic>)
      .map((e) => BatchModel.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<BatchModel>> obtenerLotes() async {
    final res = await _api.dio.get('/batches');
    await _cachear(() => _cache.guardarLotes(res.data as List<dynamic>));
    return _parseLotes(res.data);
  }

  @override
  Future<List<BatchModel>> obtenerLotesActivos() async {
    final res = await _api.dio.get('/batches/active');
    return _parseLotes(res.data);
  }

  @override
  Future<BatchModel> obtenerLotePorId(String id) async {
    final res = await _api.dio.get('/batches/$id');
    await _cachear(() => _cache.guardarLote(id, res.data as Map<String, dynamic>));
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<BatchModel> crearLote(BatchModel lote) async {
    final res = await _api.dio.post('/batches', data: lote.toCreateJson());
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<BatchModel> actualizarEstado(String id, BatchStatus nuevoEstado) async {
    final res = await _api.dio.patch('/batches/$id/status',
        data: {'estado': batchStatusToApi(nuevoEstado)});
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<BatchModel> iniciarSecado(String id) async {
    final res = await _api.dio.post('/batches/$id/start');
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<BatchModel> detenerSecado(
    String id, {
    DateTime? fechaFin,
    double? humedadFinal,
    String? clientEventId,
  }) async {
    final res = await _api.dio.post('/batches/$id/stop', data: {
      if (fechaFin != null) 'fechaFin': _iso(fechaFin),
      if (humedadFinal != null) 'humedadFinal': humedadFinal,
      if (clientEventId != null) 'clientEventId': clientEventId,
    });
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VolteoModel> registrarVolteo(
    String loteId, {
    DateTime? timestamp,
    String? clientEventId,
  }) async {
    final res = await _api.dio.post('/batches/$loteId/flip', data: {
      'metodo': 'MANUAL',
      if (timestamp != null) 'timestamp': _iso(timestamp),
      if (clientEventId != null) 'clientEventId': clientEventId,
    });
    return VolteoModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<VolteoModel>> listarVolteos(String loteId) async {
    final res = await _api.dio.get('/batches/$loteId/flips');
    await _cachear(() => _cache.guardarVolteos(loteId, res.data as List<dynamic>));
    return (res.data as List<dynamic>)
        .map((e) => VolteoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SegmentModel> cerrarSegmento(
    String loteId, {
    required DateTime finTs,
    required MotivoCierre motivo,
    double? humedadFinal,
    String? clientEventId,
  }) async {
    final res = await _api.dio.post('/batches/$loteId/segments/close', data: {
      'finTs': _iso(finTs),
      'motivo': motivo.api,
      if (humedadFinal != null) 'humedadFinal': humedadFinal,
      if (clientEventId != null) 'clientEventId': clientEventId,
    });
    return SegmentModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SegmentModel> abrirSegmento(
    String loteId, {
    required double m0,
    required DateTime inicioTs,
    String? clientEventId,
  }) async {
    final res = await _api.dio.post('/batches/$loteId/segments', data: {
      'm0': m0,
      'inicioTs': _iso(inicioTs),
      if (clientEventId != null) 'clientEventId': clientEventId,
    });
    return SegmentModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<SensorReadingModel>> obtenerLecturasLote(
    String loteId, {
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final res = await _api.dio.get('/batches/$loteId/readings', queryParameters: {
      'desde': desde.toIso8601String(),
      'hasta': hasta.toIso8601String(),
    });
    return (res.data as List<dynamic>)
        .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ManualReadingModel> registrarLecturaManual(
      String loteId, ManualReadingDraft lectura) async {
    final res = await _api.dio
        .post('/batches/$loteId/manual-readings', data: lectura.toJson());
    return ManualReadingModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<ManualReadingModel>> obtenerLecturasManuales(String loteId) async {
    final res = await _api.dio.get('/batches/$loteId/manual-readings');
    return (res.data as List<dynamic>)
        .map((e) => ManualReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PairsModel> obtenerPares(String loteId) async {
    final res = await _api.dio.get('/batches/$loteId/pairs');
    return PairsModel.fromJson(res.data as Map<String, dynamic>);
  }
}
