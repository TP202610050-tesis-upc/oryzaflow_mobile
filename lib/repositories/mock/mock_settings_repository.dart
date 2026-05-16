import '../i_settings_repository.dart';

class MockSettingsRepository implements ISettingsRepository {
  final Map<String, dynamic> _preferencias = {
    'tema': 'claro',
    'idioma': 'es',
    'unidadTemperatura': 'celsius',
    'notificacionesActivas': true,
    'sonidoAlertas': true,
    'intervaloRefresco': 30,
  };

  final Map<String, dynamic> _configSistema = {
    'urlBackend': 'http://192.168.1.1:8080',
    'versionApp': '1.0.0',
    'modoPrueba': true,
    'maximoNodos': 10,
    'retentionDays': 90,
  };

  static const _delay = Duration(milliseconds: 800);

  @override
  Future<Map<String, dynamic>> obtenerPreferencias() async {
    await Future.delayed(_delay);
    return Map.unmodifiable(_preferencias);
  }

  @override
  Future<void> guardarPreferencia(String clave, dynamic valor) async {
    await Future.delayed(_delay);
    _preferencias[clave] = valor;
  }

  @override
  Future<Map<String, dynamic>> obtenerConfiguracionSistema() async {
    await Future.delayed(_delay);
    return Map.unmodifiable(_configSistema);
  }

  @override
  Future<void> actualizarConfiguracionSistema(
      Map<String, dynamic> config) async {
    await Future.delayed(_delay);
    _configSistema.addAll(config);
  }
}
