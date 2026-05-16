import '../../core/enums/user_role.dart';
import '../../models/user_model.dart';
import '../i_user_repository.dart';
import 'mock_data.dart';

class MockUserRepository implements IUserRepository {
  final List<UserModel> _usuarios = List.from(MockData.usuarios);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<UserModel>> obtenerUsuarios() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_usuarios);
  }

  @override
  Future<UserModel> obtenerUsuarioPorId(String id) async {
    await Future.delayed(_delay);
    return _usuarios.firstWhere((u) => u.id == id,
        orElse: () => throw Exception('Usuario no encontrado'));
  }

  @override
  Future<UserModel> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    String? telefono,
  }) async {
    await Future.delayed(_delay);
    final newUser = UserModel(
      id: 'u${_usuarios.length + 1}',
      nombre: nombre,
      email: email,
      passwordHash: password,
      rol: rol,
      activo: true,
      telefono: telefono,
      creadoEn: DateTime.now(),
    );
    _usuarios.add(newUser);
    return newUser;
  }

  @override
  Future<UserModel> actualizarRol(String id, UserRole nuevoRol) async {
    await Future.delayed(_delay);
    final idx = _usuarios.indexWhere((u) => u.id == id);
    if (idx == -1) throw Exception('Usuario no encontrado');
    final updated = _usuarios[idx].copyWith(rol: nuevoRol);
    _usuarios[idx] = updated;
    return updated;
  }

  @override
  Future<UserModel> cambiarEstado(String id, bool activo) async {
    await Future.delayed(_delay);
    final idx = _usuarios.indexWhere((u) => u.id == id);
    if (idx == -1) throw Exception('Usuario no encontrado');
    final updated = _usuarios[idx].copyWith(activo: activo);
    _usuarios[idx] = updated;
    return updated;
  }

  @override
  Future<void> eliminarUsuario(String id) async {
    await Future.delayed(_delay);
    _usuarios.removeWhere((u) => u.id == id);
  }
}
