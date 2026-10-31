import '../../core/network/api_client.dart';
import '../../models/drying_profile_model.dart';
import '../i_drying_profile_repository.dart';

/// Perfiles de secado reales (master data).
class RealDryingProfileRepository implements IDryingProfileRepository {
  final ApiClient _api;

  RealDryingProfileRepository(this._api);

  @override
  Future<List<DryingProfileModel>> obtenerPerfiles() async {
    final res = await _api.dio.get('/drying-profiles');
    return (res.data as List<dynamic>)
        .map((e) => DryingProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DryingProfileModel> obtenerPerfilPorId(String id) async {
    final res = await _api.dio.get('/drying-profiles/$id');
    return DryingProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<DryingProfileModel> crearPerfil(DryingProfileModel perfil) async {
    final res = await _api.dio.post('/drying-profiles', data: perfil.toJson());
    return DryingProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<DryingProfileModel> actualizarPerfil(DryingProfileModel perfil) async {
    final res = await _api.dio.put('/drying-profiles/${perfil.id}', data: perfil.toJson());
    return DryingProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarPerfil(String id) async {
    await _api.dio.delete('/drying-profiles/$id');
  }
}
