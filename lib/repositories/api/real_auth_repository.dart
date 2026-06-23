import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../../models/user_model.dart';
import '../i_auth_repository.dart';

/// Autenticación real contra el backend. Persiste el JWT en TokenStorage; el ApiClient
/// lo adjunta a las demás peticiones y limpia la sesión ante un 401.
class RealAuthRepository implements IAuthRepository {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  RealAuthRepository(this._api, this._tokenStorage);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      await _tokenStorage.guardarToken(data['token'] as String);
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception('No se pudo iniciar sesión. Revisa tu conexión.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // Aunque falle el backend, la sesión local se cierra igual.
    } finally {
      await _tokenStorage.limpiar();
    }
  }

  @override
  Future<UserModel?> getUsuarioActual() async {
    final token = await _tokenStorage.leerToken();
    if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
      await _tokenStorage.limpiar();
      return null;
    }
    try {
      final res = await _api.dio.get('/auth/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      await _tokenStorage.limpiar();
      return null;
    }
  }

  @override
  Future<bool> estaAutenticado() async {
    final token = await _tokenStorage.leerToken();
    return token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);
  }

  @override
  Future<void> solicitarRecuperacionContrasena(String email) async {
    await _api.dio.post('/auth/password-recovery', data: {'email': email});
  }

  @override
  Future<UserModel> actualizarPerfil({
    required String userId,
    String? nombre,
    String? telefono,
  }) async {
    final res = await _api.dio.patch('/users/me', data: {
      'nombre': nombre,
      'telefono': telefono,
    });
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> cambiarContrasena({
    required String userId,
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    await _api.dio.patch('/users/me/password', data: {
      'contrasenaActual': contrasenaActual,
      'nuevaContrasena': nuevaContrasena,
    });
  }
}
