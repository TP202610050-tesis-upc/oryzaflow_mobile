import 'package:dio/dio.dart';

/// Mensaje legible de un error de red/backend. El backend responde `{ "message": "..." }` en 400/404/409
/// (GlobalExceptionHandler); ese texto es el del criterio de aceptación y se muestra tal cual.
String apiErrorMessage(Object e, {String fallback = 'Error de conexión con el servidor'}) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    final code = e.response?.statusCode;
    if (code == 401) return 'Sesión expirada. Vuelve a iniciar sesión.';
    if (code == 403) return 'No tienes permiso para esta acción.';
    if (code == 404) return 'No encontrado.';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Sin conexión con el servidor. Revisa la red e inténtalo de nuevo.';
    }
    return code != null ? 'Error $code del servidor' : fallback;
  }
  return fallback;
}
