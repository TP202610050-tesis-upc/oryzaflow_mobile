import 'package:flutter/material.dart';
import '../repositories/i_settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final ISettingsRepository _repositorio;

  SettingsProvider(this._repositorio);

  Map<String, dynamic> _preferencias = {};
  Map<String, dynamic> _configSistema = {};
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  Map<String, dynamic> get preferencias => _preferencias;
  Map<String, dynamic> get configSistema => _configSistema;
  bool get estaCargando => _cargando;
  bool get estaGuardando => _guardando;
  String? get error => _error;

  bool get notificacionesActivas =>
      _preferencias['notificacionesActivas'] as bool? ?? true;
  bool get sonidoAlertas =>
      _preferencias['sonidoAlertas'] as bool? ?? true;
  String get tema => _preferencias['tema'] as String? ?? 'claro';

  Future<void> cargarPreferencias() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final r = await Future.wait([
        _repositorio.obtenerPreferencias(),
        _repositorio.obtenerConfiguracionSistema(),
      ]);
      _preferencias = Map.from(r[0]);
      _configSistema = Map.from(r[1]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarPreferencia(String clave, dynamic valor) async {
    _guardando = true;
    notifyListeners();
    try {
      await _repositorio.guardarPreferencia(clave, valor);
      _preferencias[clave] = valor;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
