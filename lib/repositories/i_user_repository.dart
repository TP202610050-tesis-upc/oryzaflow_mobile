import '../models/user_model.dart';
import '../core/enums/user_role.dart';

abstract class IUserRepository {
  Future<List<UserModel>> obtenerUsuarios();
  Future<UserModel> obtenerUsuarioPorId(String id);
  Future<UserModel> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    String? telefono,
  });
  Future<UserModel> actualizarRol(String id, UserRole nuevoRol);
  Future<UserModel> cambiarEstado(String id, bool activo);
  Future<void> eliminarUsuario(String id);
}
