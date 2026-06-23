import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'token_storage.dart';

/// Cliente HTTP central (Dio). Adjunta el Bearer token a cada petición y, ante un
/// 401 (token vencido/revocado), limpia la sesión y notifica para forzar el logout.
class ApiClient {
  final Dio dio;
  final TokenStorage _tokenStorage;

  /// Lo cablea `main` tras construir el AuthProvider, para resetear la sesión en un 401.
  void Function()? onUnauthorized;

  ApiClient(this._tokenStorage)
      : dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          contentType: 'application/json',
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.leerToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final esLogin = e.requestOptions.path.contains('/auth/login');
        if (e.response?.statusCode == 401 && !esLogin) {
          await _tokenStorage.limpiar();
          onUnauthorized?.call();
        }
        handler.next(e);
      },
    ));
  }
}
