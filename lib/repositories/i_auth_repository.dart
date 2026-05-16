import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserModel?> getUsuarioActual();
  Future<bool> estaAutenticado();
  Future<void> solicitarRecuperacionContrasena(String email);
  Future<UserModel> actualizarPerfil({
    required String userId,
    String? nombre,
    String? telefono,
  });
  Future<void> cambiarContrasena({
    required String userId,
    required String contrasenaActual,
    required String nuevaContrasena,
  });
}
