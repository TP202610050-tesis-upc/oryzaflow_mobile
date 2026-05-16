import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../models/drying_profile_model.dart';
import '../models/node_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/silo_model.dart';
import '../models/variety_model.dart';
import '../repositories/i_batch_repository.dart';
import '../repositories/i_drying_profile_repository.dart';
import '../repositories/i_node_repository.dart';
import '../repositories/i_silo_repository.dart';
import '../repositories/i_variety_repository.dart';

class BatchProvider extends ChangeNotifier {
  final IBatchRepository _batchRepo;
  final ISiloRepository _siloRepo;
  final IVarietyRepository _varietyRepo;
  final IDryingProfileRepository _profileRepo;
  final INodeRepository _nodeRepo;

  BatchProvider(this._batchRepo, this._siloRepo, this._varietyRepo,
      this._profileRepo, this._nodeRepo);

  List<BatchModel> _lotes = [];
  BatchModel? _loteSeleccionado;
  List<SensorReadingModel> _lecturas = [];
  List<SiloModel> _silos = [];
  List<VarietyModel> _variedades = [];
  List<DryingProfileModel> _perfiles = [];
  List<NodeModel> _nodos = [];
  bool _cargando = false;
  bool _cargandoLecturas = false;
  bool _procesando = false;
  String? _error;

  List<BatchModel> get lotes => _lotes;
  BatchModel? get loteSeleccionado => _loteSeleccionado;
  List<SensorReadingModel> get lecturas => _lecturas;
  List<SiloModel> get silos => _silos;
  List<VarietyModel> get variedades => _variedades;
  List<DryingProfileModel> get perfiles => _perfiles;
  List<NodeModel> get nodos => _nodos;
  bool get estaCargando => _cargando;
  bool get estaCargandoLecturas => _cargandoLecturas;
  bool get estaProcesando => _procesando;
  String? get error => _error;

  List<BatchModel> get lotesActivos => _lotes.where((l) => l.estaActivo).toList();
  List<BatchModel> get lotesHistorial =>
      _lotes.where((l) => !l.estaActivo).toList();

  Future<void> cargarLotes() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _lotes = await _batchRepo.obtenerLotes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarLote(String id) async {
    _cargando = true;
    notifyListeners();
    try {
      _loteSeleccionado = await _batchRepo.obtenerLotePorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarLecturas(String loteId) async {
    _cargandoLecturas = true;
    notifyListeners();
    try {
      final hasta = DateTime.now();
      final desde = hasta.subtract(const Duration(hours: 2));
      _lecturas = await _batchRepo.obtenerLecturasLote(loteId,
          desde: desde, hasta: hasta);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargandoLecturas = false;
      notifyListeners();
    }
  }

  Future<void> cargarFormularioNuevoLote() async {
    _cargando = true;
    notifyListeners();
    try {
      final r = await Future.wait([
        _siloRepo.obtenerSilos(),
        _varietyRepo.obtenerVariedades(),
        _profileRepo.obtenerPerfiles(),
        _nodeRepo.obtenerNodos(),
      ]);
      _silos = r[0] as List<SiloModel>;
      _variedades = r[1] as List<VarietyModel>;
      _perfiles = r[2] as List<DryingProfileModel>;
      _nodos = r[3] as List<NodeModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<BatchModel?> crearLote(BatchModel lote) async {
    _procesando = true;
    notifyListeners();
    try {
      final nuevo = await _batchRepo.crearLote(lote);
      _lotes.insert(0, nuevo);
      notifyListeners();
      return nuevo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> iniciarSecado(String id) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _batchRepo.iniciarSecado(id);
      _actualizarLoteEnLista(updated);
      if (_loteSeleccionado?.id == id) _loteSeleccionado = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> detenerSecado(String id) async {
    _procesando = true;
    notifyListeners();
    try {
      final updated = await _batchRepo.detenerSecado(id);
      _actualizarLoteEnLista(updated);
      if (_loteSeleccionado?.id == id) _loteSeleccionado = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  void _actualizarLoteEnLista(BatchModel updated) {
    final idx = _lotes.indexWhere((l) => l.id == updated.id);
    if (idx != -1) _lotes[idx] = updated;
  }
}
