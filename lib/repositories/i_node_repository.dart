import '../models/node_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/esp32_config_model.dart';
import '../models/threshold_model.dart';
import '../core/enums/node_status.dart';

abstract class INodeRepository {
  Future<List<NodeModel>> obtenerNodos();
  Future<NodeModel> obtenerNodoPorId(String id);
  Future<List<SensorReadingModel>> obtenerLecturas(
    String nodoId, {
    required DateTime desde,
    required DateTime hasta,
  });
  Future<NodeModel> actualizarEstado(String id, NodeStatus estado);
  Future<Esp32ConfigModel> obtenerConfiguracion(String nodoId);
  Future<Esp32ConfigModel> actualizarConfiguracion(Esp32ConfigModel config);
  Future<ThresholdModel> obtenerUmbrales(String nodoId);
  Future<ThresholdModel> actualizarUmbrales(ThresholdModel umbrales);

  // Control de campo
  Future<void> activarVentilador(String nodoId, bool activar);
  Future<void> activarCalefactor(String nodoId, bool activar);
  Future<void> setModoManual(String nodoId, bool manual);
}
