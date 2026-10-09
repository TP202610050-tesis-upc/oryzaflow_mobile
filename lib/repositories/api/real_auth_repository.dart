import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error.dart';
import '../../core/network/token_storage.dart';
import '../../core/storage/offline_cache.dart';
import '../../models/user_model.dart';
import '../i_auth_repository.dart';

/// Autenticación real contra el backend. Persiste el JWT en TokenStorage; el ApiClient
/// lo adjunta a las demás peticiones y limpia la sesión ante un 401.
///
/// Sin señal (HU-010, CA-010-02): si el JWT sigue vigente y `/auth/me` falla por red, la sesión se
/// mantiene con el usuario guardado en la caché local; solo un 401 o un JWT vencido la cierran.
class RealAuthRepository implements IAuthRepository {
  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final OfflineCache _cache;

  RealAuthRepository(this._api, this._tokenStorage, this._cache);

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
      final user = data['user'] as Map<String, dynamic>;
      await _guardarUsuario(user);
      return UserModel.fromJson(user);
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
      await _cache.limpiarCacheDeSesion(); // la cola de eventos se conserva
    }
  }

  @override
  Future<UserModel?> getUsuarioActual() async {
    final token = await _tokenStorage.leerToken();
    if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
      await _tokenStorage.limpiar();
      await _cache.limpiarCacheDeSesion();
      return null;
    }
    try {
      final res = await _api.dio.get('/auth/me');
      final user = res.data as Map<String, dynamic>;
      await _guardarUsuario(user);
      return UserModel.fromJson(user);
    } on DioException catch (e) {
      if (esErrorDeRed(e) || esErrorServidor(e)) {
        // Sin señal con JWT vigente: se abre la app con el usuario cacheado y se conserva el token.
        final cacheado = await _cache.leerUsuario();
        if (cacheado != null) return UserModel.fromJson(cacheado.data);
        return null;
      }
      // 401 u otro rechazo del backend: el interceptor ya limpió el token; se cierra la sesión.
      await _tokenStorage.limpiar();
      await _cache.limpiarCacheDeSesion();
      return null;
    } catch (_) {
      await _tokenStorage.limpiar();
      await _cache.limpiarCacheDeSesion();
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
    final user = res.data as Map<String, dynamic>;
    await _guardarUsuario(user);
    return UserModel.fromJson(user);
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

  Future<void> _guardarUsuario(Map<String, dynamic> json) async {
    try {
      await _cache.guardarUsuario(json);
    } catch (_) {
      // La caché es best-effort.
    }
  }
}
