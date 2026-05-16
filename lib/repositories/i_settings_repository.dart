abstract class ISettingsRepository {
  Future<Map<String, dynamic>> obtenerPreferencias();
  Future<void> guardarPreferencia(String clave, dynamic valor);
  Future<Map<String, dynamic>> obtenerConfiguracionSistema();
  Future<void> actualizarConfiguracionSistema(Map<String, dynamic> config);
}
