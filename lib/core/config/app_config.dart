/// Configuración de red del cliente.
/// La URL base se inyecta en build time con `--dart-define=BASE_URL=...`.
/// Sin definirla, usa el default local (túnel USB `adb reverse tcp:8080 tcp:8080`).
///   Producción:
///   flutter build apk --release --dart-define=BASE_URL=https://oryzaflowbackend-production.up.railway.app
class AppConfig {
  AppConfig._();

  /// URL base del backend (sin el prefijo de API). Configurable por `--dart-define=BASE_URL`.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Prefijo común de los endpoints REST.
  static const String apiPrefix = '/api/v1';

  /// URL base completa para las llamadas REST.
  static const String apiBaseUrl = '$baseUrl$apiPrefix';
}
