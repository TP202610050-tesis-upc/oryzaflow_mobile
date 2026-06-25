import '../../core/network/api_client.dart';
import '../../core/enums/user_role.dart';
import '../../core/network/json_mappers.dart';
import '../../models/user_model.dart';
import '../i_user_repository.dart';

/// Gestión de usuarios real (solo-admin). Roles en requests = ROLE_* (con prefijo).
class RealUserRepository implements IUserRepository {
  final ApiClient _api;

  RealUserRepository(this._api);

  @override
  Future<List<UserModel>> obtenerUsuarios() async {
    final res = await _api.dio.get('/users');
    return (res.data as List<dynamic>)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> obtenerUsuarioPorId(String id) async {
    final res = await _api.dio.get('/users/$id');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    String? telefono,
  }) async {
    final res = await _api.dio.post('/users', data: {
      'nombre': nombre,
      'email': email,
      'password': password,
      'telefono': telefono,
      'roles': [userRoleToApi(rol)],
    });
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> actualizarRol(String id, UserRole nuevoRol) async {
    final res = await _api.dio
        .patch('/users/$id/role', data: {'rol': userRoleToApi(nuevoRol)});
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> cambiarEstado(String id, bool activo) async {
    final res = await _api.dio.patch('/users/$id/status', data: {'activo': activo});
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarUsuario(String id) async {
    await _api.dio.delete('/users/$id');
  }
}
