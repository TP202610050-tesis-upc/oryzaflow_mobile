import '../../core/enums/batch_status.dart';
import '../../core/enums/drying_stage.dart';
import '../../models/batch_model.dart';
import '../../models/sensor_reading_model.dart';
import '../i_batch_repository.dart';
import 'mock_data.dart';

class MockBatchRepository implements IBatchRepository {
  final List<BatchModel> _lotes = List.from(MockData.lotes);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<BatchModel>> obtenerLotes() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_lotes);
  }

  @override
  Future<List<BatchModel>> obtenerLotesActivos() async {
    await Future.delayed(_delay);
    return _lotes.where((l) => l.estaActivo).toList();
  }

  @override
  Future<BatchModel> obtenerLotePorId(String id) async {
    await Future.delayed(_delay);
    return _lotes.firstWhere((l) => l.id == id,
        orElse: () => throw Exception('Lote no encontrado'));
  }

  @override
  Future<BatchModel> crearLote(BatchModel lote) async {
    await Future.delayed(_delay);
    _lotes.add(lote);
    return lote;
  }

  @override
  Future<BatchModel> actualizarEstado(
      String id, BatchStatus nuevoEstado) async {
    await Future.delayed(_delay);
    final idx = _lotes.indexWhere((l) => l.id == id);
    if (idx == -1) throw Exception('Lote no encontrado');
    final updated = _lotes[idx].copyWith(estado: nuevoEstado);
    _lotes[idx] = updated;
    return updated;
  }

  @override
  Future<BatchModel> iniciarSecado(String id) async {
    await Future.delayed(_delay);
    final idx = _lotes.indexWhere((l) => l.id == id);
    if (idx == -1) throw Exception('Lote no encontrado');
    final updated = _lotes[idx].copyWith(
      estado: BatchStatus.enProceso,
      etapaActual: DryingStage.precalentamiento,
      fechaInicio: DateTime.now(),
    );
    _lotes[idx] = updated;
    return updated;
  }

  @override
  Future<BatchModel> detenerSecado(String id) async {
    await Future.delayed(_delay);
    final idx = _lotes.indexWhere((l) => l.id == id);
    if (idx == -1) throw Exception('Lote no encontrado');
    final updated = _lotes[idx].copyWith(
      estado: BatchStatus.completado,
      etapaActual: DryingStage.completado,
      fechaFin: DateTime.now(),
    );
    _lotes[idx] = updated;
    return updated;
  }

  @override
  Future<List<SensorReadingModel>> obtenerLecturasLote(
    String loteId, {
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(_delay);
    final lote = _lotes.firstWhere((l) => l.id == loteId,
        orElse: () => throw Exception('Lote no encontrado'));
    return MockData.generarLecturas(lote.nodoId, desde: desde, hasta: hasta);
  }
}
