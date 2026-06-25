import 'package:flutter/material.dart';
import '../models/esp32_config_model.dart';
import '../models/node_model.dart';
import '../models/sensor_reading_model.dart';
import '../repositories/i_node_repository.dart';
import '../core/enums/node_status.dart';

class MonitoringProvider extends ChangeNotifier {
  final INodeRepository _repositorio;

  MonitoringProvider(this._repositorio);

  List<NodeModel> _nodos = [];
  NodeModel? _nodoSeleccionado;
  List<SensorReadingModel> _lecturas = [];
  Esp32ConfigModel? _config;
  bool _cargando = false;
  bool _cargandoLecturas = false;
  bool _procesando = false;
  String? _error;

  List<NodeModel> get nodos => _nodos;
  NodeModel? get nodoSeleccionado => _nodoSeleccionado;
  List<SensorReadingModel> get lecturas => _lecturas;
  Esp32ConfigModel? get config => _config;
  bool get estaCargando => _cargando;
  bool get estaCargandoLecturas => _cargandoLecturas;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  Future<void> cargarNodos() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _nodos = await _repositorio.obtenerNodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarNodo(String id) async {
    _cargando = true;
    notifyListeners();
    try {
      _nodoSeleccionado = await _repositorio.obtenerNodoPorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarLecturas(String nodoId) async {
    _cargandoLecturas = true;
    notifyListeners();
    try {
      final hasta = DateTime.now();
      final desde = hasta.subtract(const Duration(hours: 2));
      _lecturas = await _repositorio.obtenerLecturas(nodoId,
          desde: desde, hasta: hasta);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargandoLecturas = false;
      notifyListeners();
    }
  }

  Future<void> cargarConfig(String nodoId) async {
    _cargando = true;
    notifyListeners();
    try {
      _config = await _repositorio.obtenerConfiguracion(nodoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarConfig(Esp32ConfigModel config) async {
    _procesando = true;
    notifyListeners();
    try {
      _config = await _repositorio.actualizarConfiguracion(config);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<NodeModel> actualizarEstado(String id, NodeStatus estado) async {
    final updated = await _repositorio.actualizarEstado(id, estado);
    final idx = _nodos.indexWhere((n) => n.id == id);
    if (idx != -1) _nodos[idx] = updated;
    if (_nodoSeleccionado?.id == id) _nodoSeleccionado = updated;
    notifyListeners();
    return updated;
  }
}
