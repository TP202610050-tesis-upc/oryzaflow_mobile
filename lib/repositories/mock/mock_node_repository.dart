import '../../core/enums/node_status.dart';
import '../../models/esp32_config_model.dart';
import '../../models/node_model.dart';
import '../../models/sensor_reading_model.dart';
import '../../models/threshold_model.dart';
import '../../models/volteo_model.dart';
import '../i_node_repository.dart';
import 'mock_data.dart';

class MockNodeRepository implements INodeRepository {
  final List<NodeModel> _nodos = List.from(MockData.nodos);
  final Map<String, Esp32ConfigModel> _configs =
      Map.from(MockData.configuraciones);
  final Map<String, ThresholdModel> _umbrales = Map.from(MockData.umbrales);
  int _volteoSeq = 0;
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<NodeModel>> obtenerNodos() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_nodos);
  }

  @override
  Future<NodeModel> obtenerNodoPorId(String id) async {
    await Future.delayed(_delay);
    return _nodos.firstWhere((n) => n.id == id,
        orElse: () => throw Exception('Nodo no encontrado: $id'));
  }

  @override
  Future<List<SensorReadingModel>> obtenerLecturas(
    String nodoId, {
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(_delay);
    return MockData.generarLecturas(nodoId, desde: desde, hasta: hasta);
  }

  @override
  Future<NodeModel> actualizarEstado(String id, NodeStatus estado) async {
    await Future.delayed(_delay);
    final idx = _nodos.indexWhere((n) => n.id == id);
    if (idx == -1) throw Exception('Nodo no encontrado');
    final updated = _nodos[idx].copyWith(estado: estado);
    _nodos[idx] = updated;
    return updated;
  }

  @override
  Future<Esp32ConfigModel> obtenerConfiguracion(String nodoId) async {
    await Future.delayed(_delay);
    return _configs[nodoId] ??
        (throw Exception('Configuración no encontrada para $nodoId'));
  }

  @override
  Future<Esp32ConfigModel> actualizarConfiguracion(
      Esp32ConfigModel config) async {
    await Future.delayed(_delay);
    _configs[config.nodoId] = config;
    return config;
  }

  @override
  Future<ThresholdModel> obtenerUmbrales(String nodoId) async {
    await Future.delayed(_delay);
    return _umbrales[nodoId] ??
        (throw Exception('Umbrales no encontrados para $nodoId'));
  }

  @override
  Future<ThresholdModel> actualizarUmbrales(ThresholdModel umbrales) async {
    await Future.delayed(_delay);
    _umbrales[umbrales.nodoId] = umbrales;
    return umbrales;
  }

  @override
  Future<VolteoModel> registrarVolteo(String nodoId) async {
    await Future.delayed(_delay);
    return VolteoModel(
      id: 'volteo-${++_volteoSeq}',
      nodoId: nodoId,
      metodo: MetodoVolteo.manual,
      timestamp: DateTime.now(),
    );
  }
}
