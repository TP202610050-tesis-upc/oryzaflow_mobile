import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../models/alert_model.dart';
import '../repositories/i_alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  final IAlertRepository _repositorio;

  AlertProvider(this._repositorio);

  List<AlertModel> _alertas = [];
  bool _cargando = false;
  bool _procesando = false;
  String? _error;

  // §7.4: el DELETE se difiere; si el usuario deshace antes, se cancela.
  static const _ventanaUndo = Duration(seconds: 5);
  final Map<String, Timer> _eliminacionesPendientes = {};

  List<AlertModel> get alertas => _alertas;
  List<AlertModel> get noLeidas => _alertas.where((a) => !a.leida).toList();
  int get cantidadNoLeidas => noLeidas.length;
  // CA-015-02: alertas reenviadas al supervisor por no atenderse a tiempo.
  List<AlertModel> get escaladas => _alertas.where((a) => a.escalada).toList();
  int get cantidadEscaladas => escaladas.length;
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
      _error = apiErrorMessage(e);
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

  /// Quita la alerta de la lista al instante y programa el descarte real tras la ventana de
  /// "Deshacer"; si el usuario deshace antes, [restaurarAlerta] cancela el envío.
  Future<bool> eliminarAlerta(String id) async {
    final idx = _alertas.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    _alertas.removeAt(idx);
    notifyListeners();

    _eliminacionesPendientes[id]?.cancel();
    _eliminacionesPendientes[id] = Timer(_ventanaUndo, () async {
      _eliminacionesPendientes.remove(id);
      try {
        await _repositorio.eliminarAlerta(id);
      } catch (e) {
        _error = apiErrorMessage(e);
      }
    });
    return true;
  }

  void restaurarAlerta(AlertModel alerta) {
    _eliminacionesPendientes.remove(alerta.id)?.cancel();
    final idx =
        _alertas.indexWhere((a) => a.timestamp.isBefore(alerta.timestamp));
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
      _error = apiErrorMessage(e);
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final t in _eliminacionesPendientes.values) {
      t.cancel();
    }
    _eliminacionesPendientes.clear();
    super.dispose();
  }
}
