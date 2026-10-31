import '../../core/network/api_client.dart';
import '../../core/enums/node_status.dart';
import '../../models/esp32_config_model.dart';
import '../../models/node_model.dart';
import '../../models/sensor_reading_model.dart';
import '../i_node_repository.dart';

/// Nodos reales (BC3). Config = /config + /calibration; lecturas = /nodes/{id}/readings.
/// Umbrales (#43-44) se cubren vía masterdata (variedad/perfil); volteo (#45) es por lote
/// (POST /batches/{id}/flip) — ver docs §7.9 y §7.10.
class RealNodeRepository implements INodeRepository {
  final ApiClient _api;

  RealNodeRepository(this._api);

  @override
  Future<List<NodeModel>> obtenerNodos() async {
    final res = await _api.dio.get('/nodes');
    return (res.data as List<dynamic>)
        .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NodeModel> obtenerNodoPorId(String id) async {
    final res = await _api.dio.get('/nodes/$id');
    return NodeModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<SensorReadingModel>> obtenerLecturas(
    String nodoId, {
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final res = await _api.dio.get('/nodes/$nodoId/readings', queryParameters: {
      'desde': desde.toIso8601String(),
      'hasta': hasta.toIso8601String(),
    });
    return (res.data as List<dynamic>)
        .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// El estado del nodo es runtime (lo fija la ingesta/watchdog); no hay endpoint para forzarlo.
  /// Devuelve el nodo actual sin cambiarlo.
  @override
  Future<NodeModel> actualizarEstado(String id, NodeStatus estado) =>
      obtenerNodoPorId(id);

  @override
  Future<Esp32ConfigModel> obtenerConfiguracion(String nodoId) async {
    final res = await _api.dio.get('/nodes/$nodoId');
    return Esp32ConfigModel.fromNodeJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Esp32ConfigModel> actualizarConfiguracion(Esp32ConfigModel config) async {
    await _api.dio.put('/nodes/${config.nodoId}/config', data: config.toConfigJson());
    final res = await _api.dio
        .put('/nodes/${config.nodoId}/calibration', data: config.toCalibrationJson());
    return Esp32ConfigModel.fromNodeJson(res.data as Map<String, dynamic>);
  }
}
