import '../../models/user_model.dart';
import '../i_auth_repository.dart';
import 'mock_data.dart';

class MockAuthRepository implements IAuthRepository {
  UserModel? _currentUser;
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_delay);
    final matches = MockData.usuarios.where(
      (u) => u.email == email && u.passwordHash == password,
    ).toList();
    if (matches.isEmpty) throw Exception('Correo o contraseña incorrectos');
    final match = matches.first;
    if (!match.activo) throw Exception('La cuenta está desactivada');
    _currentUser = match;
    return match;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_delay);
    _currentUser = null;
  }

  @override
  Future<UserModel?> getUsuarioActual() async {
    await Future.delayed(_delay);
    return _currentUser;
  }

  @override
  Future<bool> estaAutenticado() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser != null;
  }

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {
    await Future.delayed(_delay);
    final existe = MockData.usuarios.any((u) => u.email == email);
    if (!existe) throw Exception('No existe una cuenta con ese correo');
  }

  @override
  Future<UserModel> actualizarPerfil({
    required String userId,
    String? nombre,
    String? telefono,
  }) async {
    await Future.delayed(_delay);
    if (_currentUser == null) throw Exception('No autenticado');
    final updated = _currentUser!.copyWith(
      nombre: nombre,
      telefono: telefono,
    );
    _currentUser = updated;
    return updated;
  }

  @override
  Future<void> cambiarContrasena({
    required String userId,
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    await Future.delayed(_delay);
    if (_currentUser?.passwordHash != contrasenaActual) {
      throw Exception('La contraseña actual es incorrecta');
    }
  }
}
