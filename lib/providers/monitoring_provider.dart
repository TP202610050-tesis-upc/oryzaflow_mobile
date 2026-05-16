import 'package:flutter/material.dart';
import '../models/esp32_config_model.dart';
import '../models/node_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/threshold_model.dart';
import '../repositories/i_node_repository.dart';
import '../core/enums/node_status.dart';

class MonitoringProvider extends ChangeNotifier {
  final INodeRepository _repositorio;

  MonitoringProvider(this._repositorio);

  List<NodeModel> _nodos = [];
  NodeModel? _nodoSeleccionado;
  List<SensorReadingModel> _lecturas = [];
  Esp32ConfigModel? _config;
  ThresholdModel? _umbrales;
  final Map<String, bool> _ventiladores = {};
  final Map<String, bool> _calefactores = {};
  final Map<String, bool> _modoManual = {};
  bool _cargando = false;
  bool _cargandoLecturas = false;
  bool _procesando = false;
  String? _error;

  List<NodeModel> get nodos => _nodos;
  NodeModel? get nodoSeleccionado => _nodoSeleccionado;
  List<SensorReadingModel> get lecturas => _lecturas;
  Esp32ConfigModel? get config => _config;
  ThresholdModel? get umbrales => _umbrales;
  bool get estaCargando => _cargando;
  bool get estaCargandoLecturas => _cargandoLecturas;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  bool ventiladorActivo(String nodoId) => _ventiladores[nodoId] ?? false;
  bool calefactorActivo(String nodoId) => _calefactores[nodoId] ?? false;
  bool esModoManual(String nodoId) => _modoManual[nodoId] ?? false;

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
      final r = await Future.wait([
        _repositorio.obtenerConfiguracion(nodoId),
        _repositorio.obtenerUmbrales(nodoId),
      ]);
      _config = r[0] as Esp32ConfigModel;
      _umbrales = r[1] as ThresholdModel;
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

  Future<bool> guardarUmbrales(ThresholdModel u) async {
    _procesando = true;
    notifyListeners();
    try {
      _umbrales = await _repositorio.actualizarUmbrales(u);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<void> toggleVentilador(String nodoId) async {
    final current = ventiladorActivo(nodoId);
    await _repositorio.activarVentilador(nodoId, !current);
    _ventiladores[nodoId] = !current;
    notifyListeners();
  }

  Future<void> toggleCalefactor(String nodoId) async {
    final current = calefactorActivo(nodoId);
    await _repositorio.activarCalefactor(nodoId, !current);
    _calefactores[nodoId] = !current;
    notifyListeners();
  }

  Future<void> toggleModoManual(String nodoId) async {
    final current = esModoManual(nodoId);
    await _repositorio.setModoManual(nodoId, !current);
    _modoManual[nodoId] = !current;
    notifyListeners();
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
