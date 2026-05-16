import '../../models/drying_profile_model.dart';
import '../i_drying_profile_repository.dart';
import 'mock_data.dart';

class MockDryingProfileRepository implements IDryingProfileRepository {
  final List<DryingProfileModel> _perfiles = List.from(MockData.perfiles);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<DryingProfileModel>> obtenerPerfiles() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_perfiles);
  }

  @override
  Future<DryingProfileModel> obtenerPerfilPorId(String id) async {
    await Future.delayed(_delay);
    return _perfiles.firstWhere((p) => p.id == id,
        orElse: () => throw Exception('Perfil no encontrado'));
  }

  @override
  Future<DryingProfileModel> crearPerfil(DryingProfileModel perfil) async {
    await Future.delayed(_delay);
    _perfiles.add(perfil);
    return perfil;
  }

  @override
  Future<DryingProfileModel> actualizarPerfil(
      DryingProfileModel perfil) async {
    await Future.delayed(_delay);
    final idx = _perfiles.indexWhere((p) => p.id == perfil.id);
    if (idx == -1) throw Exception('Perfil no encontrado');
    _perfiles[idx] = perfil;
    return perfil;
  }

  @override
  Future<void> eliminarPerfil(String id) async {
    await Future.delayed(_delay);
    _perfiles.removeWhere((p) => p.id == id);
  }
}
