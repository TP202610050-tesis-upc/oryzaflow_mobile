/// Configuración de red del cliente. El backend se alcanza vía túnel USB
/// (`adb reverse tcp:8080 tcp:8080`), por eso el host es `localhost`.
class AppConfig {
  AppConfig._();

  /// URL base del backend (sin el prefijo de API).
  static const String baseUrl = 'http://localhost:8080';

  /// Prefijo común de los endpoints REST.
  static const String apiPrefix = '/api/v1';

  /// URL base completa para las llamadas REST.
  static const String apiBaseUrl = '$baseUrl$apiPrefix';
}
