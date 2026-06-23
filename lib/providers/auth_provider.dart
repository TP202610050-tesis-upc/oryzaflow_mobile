import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/i_auth_repository.dart';

enum AuthEstado { inicial, cargando, autenticado, noAutenticado, error }

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repositorio;

  AuthProvider(this._repositorio);

  AuthEstado _estado = AuthEstado.inicial;
  UserModel? _usuario;
  String? _error;

  AuthEstado get estado => _estado;
  UserModel? get usuario => _usuario;
  String? get error => _error;
  bool get estaAutenticado => _estado == AuthEstado.autenticado;
  bool get estaCargando => _estado == AuthEstado.cargando;

  Future<void> verificarAutenticacion() async {
    _estado = AuthEstado.cargando;
    notifyListeners();
    try {
      _usuario = await _repositorio.getUsuarioActual();
      _estado = _usuario != null
          ? AuthEstado.autenticado
          : AuthEstado.noAutenticado;
    } catch (_) {
      _estado = AuthEstado.noAutenticado;
    }
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    _estado = AuthEstado.cargando;
    _error = null;
    notifyListeners();
    try {
      _usuario = await _repositorio.login(email: email, password: password);
      _estado = AuthEstado.autenticado;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _estado = AuthEstado.noAutenticado;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _repositorio.logout();
    _usuario = null;
    _estado = AuthEstado.noAutenticado;
    notifyListeners();
  }

  /// Llamado por el ApiClient ante un 401 (token vencido/revocado): resetea la sesión
  /// localmente sin golpear al backend, para que el guard del router lleve a login.
  void sesionExpirada() {
    if (_estado == AuthEstado.noAutenticado && _usuario == null) return;
    _usuario = null;
    _estado = AuthEstado.noAutenticado;
    notifyListeners();
  }

  Future<void> solicitarRecuperacion(String email) =>
      _repositorio.solicitarRecuperacionContrasena(email);

  Future<UserModel> actualizarPerfil({
    required String userId,
    String? nombre,
    String? telefono,
  }) async {
    final updated = await _repositorio.actualizarPerfil(
        userId: userId, nombre: nombre, telefono: telefono);
    _usuario = updated;
    notifyListeners();
    return updated;
  }

  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) {
    final usuario = _usuario;
    if (usuario == null) {
      throw Exception('No hay una sesión activa');
    }
    return _repositorio.cambiarContrasena(
      userId: usuario.id,
      contrasenaActual: contrasenaActual,
      nuevaContrasena: nuevaContrasena,
    );
  }
}
