import '../models/batch_model.dart';
import '../models/manual_reading_model.dart';
import '../models/pair_model.dart';
import '../models/segment_model.dart';
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

  /// Detiene el lote (orden de recojo). `fechaFin` y `clientEventId` permiten sincronizar un
  /// evento registrado sin señal con su hora original (HU-010, CA-010-02); `humedadFinal` es la
  /// lectura final del PM-410 (% b.h., 5–40).
  Future<BatchModel> detenerSecado(
    String id, {
    DateTime? fechaFin,
    double? humedadFinal,
    String? clientEventId,
  });

  /// Registra un volteo del grano del lote (#45 → POST /batches/{id}/flip).
  Future<VolteoModel> registrarVolteo(
    String loteId, {
    DateTime? timestamp,
    String? clientEventId,
  });

  /// Volteos del lote con su hora original (GET /batches/{id}/flips).
  Future<List<VolteoModel>> listarVolteos(String loteId);

  /// "Cubrir": cierra el segmento diario abierto (POST /batches/{id}/segments/close).
  Future<SegmentModel> cerrarSegmento(
    String loteId, {
    required DateTime finTs,
    required MotivoCierre motivo,
    double? humedadFinal,
    String? clientEventId,
  });

  /// "Descubrir": abre el segmento siguiente con la M0 del PM-410 (POST /batches/{id}/segments).
  Future<SegmentModel> abrirSegmento(
    String loteId, {
    required double m0,
    required DateTime inicioTs,
    String? clientEventId,
  });

  Future<List<SensorReadingModel>> obtenerLecturasLote(
    String loteId, {
    required DateTime desde,
    required DateTime hasta,
  });

  /// Lecturas manuales del medidor PM-410 (F7, HU-013): #49/#50/#51.
  Future<ManualReadingModel> registrarLecturaManual(String loteId, ManualReadingDraft lectura);
  Future<List<ManualReadingModel>> obtenerLecturasManuales(String loteId);
  Future<PairsModel> obtenerPares(String loteId);
}
