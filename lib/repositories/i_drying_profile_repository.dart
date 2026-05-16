import '../models/drying_profile_model.dart';

abstract class IDryingProfileRepository {
  Future<List<DryingProfileModel>> obtenerPerfiles();
  Future<DryingProfileModel> obtenerPerfilPorId(String id);
  Future<DryingProfileModel> crearPerfil(DryingProfileModel perfil);
  Future<DryingProfileModel> actualizarPerfil(DryingProfileModel perfil);
  Future<void> eliminarPerfil(String id);
}
