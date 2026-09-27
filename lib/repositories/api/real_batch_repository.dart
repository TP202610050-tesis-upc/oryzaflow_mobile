import '../../core/network/api_client.dart';
import '../../core/network/json_mappers.dart';
import '../../core/enums/batch_status.dart';
import '../../models/batch_model.dart';
import '../../models/manual_reading_model.dart';
import '../../models/pair_model.dart';
import '../../models/sensor_reading_model.dart';
import '../../models/volteo_model.dart';
import '../i_batch_repository.dart';

/// Lotes de secado reales (BC4): ciclo de vida, lecturas de telemetría y lecturas manuales del medidor.
class RealBatchRepository implements IBatchRepository {
  final ApiClient _api;

  RealBatchRepository(this._api);

  List<BatchModel> _parseLotes(dynamic data) => (data as List<dynamic>)
      .map((e) => BatchModel.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<BatchModel>> obtenerLotes() async {
    final res = await _api.dio.get('/batches');
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
  Future<BatchModel> detenerSecado(String id) async {
    final res = await _api.dio.post('/batches/$id/stop');
    return BatchModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VolteoModel> registrarVolteo(String loteId) async {
    final res = await _api.dio.post('/batches/$loteId/flip');
    return VolteoModel.fromJson(res.data as Map<String, dynamic>);
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
