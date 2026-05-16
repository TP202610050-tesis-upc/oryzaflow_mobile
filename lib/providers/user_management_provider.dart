import 'package:flutter/material.dart';
import '../core/enums/user_role.dart';
import '../models/user_model.dart';
import '../repositories/i_user_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final IUserRepository _repositorio;

  UserManagementProvider(this._repositorio);

  List<UserModel> _usuarios = [];
  UserModel? _usuarioSeleccionado;
  bool _cargando = false;
  bool _procesando = false;
  String? _error;

  List<UserModel> get usuarios => _usuarios;
  UserModel? get usuarioSeleccionado => _usuarioSeleccionado;
  bool get estaCargando => _cargando;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  Future<void> cargarUsuarios() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuarios = await _repositorio.obtenerUsuarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarUsuario(String id) async {
    _cargando = true;
    notifyListeners();
    try {
      _usuarioSeleccionado = await _repositorio.obtenerUsuarioPorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<UserModel?> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    String? telefono,
  }) async {
    _procesando = true;
    notifyListeners();
    try {
      final nuevo = await _repositorio.crearUsuario(
          nombre: nombre, email: email, password: password,
          rol: rol, telefono: telefono);
      _usuarios.add(nuevo);
      notifyListeners();
      return nuevo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarRol(String id, UserRole nuevoRol) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _repositorio.actualizarRol(id, nuevoRol);
      _reemplazarEnLista(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(String id, bool activo) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _repositorio.cambiarEstado(id, activo);
      _reemplazarEnLista(updated);
      if (_usuarioSeleccionado?.id == id) _usuarioSeleccionado = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  void _reemplazarEnLista(UserModel u) {
    final idx = _usuarios.indexWhere((x) => x.id == u.id);
    if (idx != -1) _usuarios[idx] = u;
  }
}
