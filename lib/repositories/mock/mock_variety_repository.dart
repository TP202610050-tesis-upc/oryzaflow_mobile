import '../../models/variety_model.dart';
import '../i_variety_repository.dart';
import 'mock_data.dart';

class MockVarietyRepository implements IVarietyRepository {
  final List<VarietyModel> _variedades = List.from(MockData.variedades);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<VarietyModel>> obtenerVariedades() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_variedades);
  }

  @override
  Future<VarietyModel> obtenerVariedadPorId(String id) async {
    await Future.delayed(_delay);
    return _variedades.firstWhere((v) => v.id == id,
        orElse: () => throw Exception('Variedad no encontrada'));
  }

  @override
  Future<VarietyModel> crearVariedad(VarietyModel variedad) async {
    await Future.delayed(_delay);
    _variedades.add(variedad);
    return variedad;
  }

  @override
  Future<VarietyModel> actualizarVariedad(VarietyModel variedad) async {
    await Future.delayed(_delay);
    final idx = _variedades.indexWhere((v) => v.id == variedad.id);
    if (idx == -1) throw Exception('Variedad no encontrada');
    _variedades[idx] = variedad;
    return variedad;
  }

  @override
  Future<void> eliminarVariedad(String id) async {
    await Future.delayed(_delay);
    _variedades.removeWhere((v) => v.id == id);
  }
}
