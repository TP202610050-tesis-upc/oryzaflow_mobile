import '../models/batch_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/volteo_model.dart';
import '../core/enums/batch_status.dart';

abstract class IBatchRepository {
  Future<List<BatchModel>> obtenerLotes();
  Future<List<BatchModel>> obtenerLotesActivos();
  Future<BatchModel> obtenerLotePorId(String id);
  Future<BatchModel> crearLote(BatchModel lote);
  Future<BatchModel> actualizarEstado(String id, BatchStatus nuevoEstado);
  Future<BatchModel> iniciarSecado(String id);
  Future<BatchModel> detenerSecado(String id);

  /// Registra un volteo del grano del lote (#45 → POST /batches/{id}/flip).
  Future<VolteoModel> registrarVolteo(String loteId);
  Future<List<SensorReadingModel>> obtenerLecturasLote(
    String loteId, {
    required DateTime desde,
    required DateTime hasta,
  });
}
