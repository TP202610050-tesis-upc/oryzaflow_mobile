import '../../models/silo_model.dart';
import '../i_silo_repository.dart';
import 'mock_data.dart';

class MockSiloRepository implements ISiloRepository {
  final List<SiloModel> _silos = List.from(MockData.silos);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<SiloModel>> obtenerSilos() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_silos);
  }

  @override
  Future<SiloModel> obtenerSiloPorId(String id) async {
    await Future.delayed(_delay);
    return _silos.firstWhere((s) => s.id == id,
        orElse: () => throw Exception('Silo no encontrado'));
  }

  @override
  Future<SiloModel> crearSilo(SiloModel silo) async {
    await Future.delayed(_delay);
    _silos.add(silo);
    return silo;
  }

  @override
  Future<SiloModel> actualizarSilo(SiloModel silo) async {
    await Future.delayed(_delay);
    final idx = _silos.indexWhere((s) => s.id == silo.id);
    if (idx == -1) throw Exception('Silo no encontrado');
    _silos[idx] = silo;
    return silo;
  }

  @override
  Future<void> eliminarSilo(String id) async {
    await Future.delayed(_delay);
    _silos.removeWhere((s) => s.id == id);
  }

  @override
  Future<Map<DateTime, List<SiloModel>>> obtenerDisponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(_delay);
    final result = <DateTime, List<SiloModel>>{};
    var current = DateTime(desde.year, desde.month, desde.day);
    while (!current.isAfter(hasta)) {
      result[current] = List.from(_silos);
      current = current.add(const Duration(days: 1));
    }
    return result;
  }
}
