import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../repositories/i_alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  final IAlertRepository _repositorio;

  AlertProvider(this._repositorio);

  List<AlertModel> _alertas = [];
  bool _cargando = false;
  bool _procesando = false;
  String? _error;

  List<AlertModel> get alertas => _alertas;
  List<AlertModel> get noLeidas => _alertas.where((a) => !a.leida).toList();
  int get cantidadNoLeidas => noLeidas.length;
  bool get estaCargando => _cargando;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  Future<void> cargarAlertas({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = _alertas.isEmpty;
      _error = null;
      if (_cargando) notifyListeners();
    }
    try {
      _alertas = await _repositorio.obtenerAlertas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> marcarLeida(String id) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _repositorio.marcarComoLeida(id);
      final idx = _alertas.indexWhere((a) => a.id == id);
      if (idx != -1) _alertas[idx] = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarAlerta(String id) async {
    _alertas.removeWhere((a) => a.id == id);
    notifyListeners();
    return true;
  }

  void restaurarAlerta(AlertModel alerta) {
    final idx = _alertas.indexWhere(
        (a) => a.timestamp.isBefore(alerta.timestamp));
    if (idx == -1) {
      _alertas.add(alerta);
    } else {
      _alertas.insert(idx, alerta);
    }
    notifyListeners();
  }

  Future<void> marcarTodasLeidas() async {
    _procesando = true;
    notifyListeners();
    try {
      await _repositorio.marcarTodasComoLeidas();
      _alertas = _alertas.map((a) => a.copyWith(leida: true)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }
}
