import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../models/batch_model.dart';
import '../models/drying_profile_model.dart';
import '../models/manual_reading_model.dart';
import '../models/node_model.dart';
import '../models/pair_model.dart';
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
  List<ManualReadingModel> _lecturasManuales = [];
  PairsModel? _pares;
  bool _cargando = false;
  bool _cargandoLecturas = false;
  bool _cargandoPares = false;
  bool _procesando = false;
  String? _error;

  List<BatchModel> get lotes => _lotes;
  BatchModel? get loteSeleccionado => _loteSeleccionado;
  List<SensorReadingModel> get lecturas => _lecturas;
  List<SiloModel> get silos => _silos;
  List<VarietyModel> get variedades => _variedades;
  List<DryingProfileModel> get perfiles => _perfiles;
  List<NodeModel> get nodos => _nodos;
  List<ManualReadingModel> get lecturasManuales => _lecturasManuales;
  PairsModel? get pares => _pares;
  bool get estaCargando => _cargando;
  bool get estaCargandoLecturas => _cargandoLecturas;
  bool get estaCargandoPares => _cargandoPares;
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
      _lotes = List.of(await _batchRepo.obtenerLotes());
    } catch (e) {
      _error = apiErrorMessage(e);
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
      _error = apiErrorMessage(e);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Refresca solo el lote (estimación, marca "por verificar", alertas) sin pasar por el estado de carga.
  Future<void> refrescarLote(String id) async {
    try {
      _loteSeleccionado = await _batchRepo.obtenerLotePorId(id);
      _actualizarLoteEnLista(_loteSeleccionado!);
      notifyListeners();
    } catch (_) {}
  }

  /// Lecturas para las gráficas del lote: todo su periodo (inicio → cierre, o → ahora si sigue en proceso),
  /// no una ventana relativa a «ahora»; así un lote cerrado conserva su curva. El backend recorta la ventana
  /// a [fechaInicio, fechaFin] del lote.
  Future<void> cargarLecturas(String loteId) async {
    _cargandoLecturas = true;
    notifyListeners();
    try {
      final lote = _loteSeleccionado?.id == loteId
          ? _loteSeleccionado!
          : await _batchRepo.obtenerLotePorId(loteId);
      final hasta = lote.fechaFin ?? DateTime.now();
      final desde = lote.fechaInicio ?? lote.fechaIngreso;
      _lecturas = await _batchRepo.obtenerLecturasLote(loteId,
          desde: desde, hasta: hasta);
    } catch (e) {
      _error = apiErrorMessage(e);
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
      _error = apiErrorMessage(e);
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
      _error = apiErrorMessage(e);
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
      _error = apiErrorMessage(e);
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
      _error = apiErrorMessage(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  /// Registra un volteo manual del lote (#45). No altera el lote; devuelve éxito/fallo.
  Future<bool> registrarVolteo(String id) async {
    _procesando = true;
    notifyListeners();
    try {
      await _batchRepo.registrarVolteo(id);
      return true;
    } catch (e) {
      _error = apiErrorMessage(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ---- Lecturas manuales del medidor y pares (HU-013, CA-013-01/02) ----

  Future<void> cargarPares(String loteId) async {
    _cargandoPares = true;
    notifyListeners();
    try {
      final r = await Future.wait([
        _batchRepo.obtenerPares(loteId),
        _batchRepo.obtenerLecturasManuales(loteId),
      ]);
      _pares = r[0] as PairsModel;
      _lecturasManuales = r[1] as List<ManualReadingModel>;
    } catch (e) {
      _error = apiErrorMessage(e);
    } finally {
      _cargandoPares = false;
      notifyListeners();
    }
  }

  /// Registra la lectura del PM-410 y recarga pares y lote (la marca "por verificar" la decide el backend).
  Future<ManualReadingModel?> registrarLecturaManual(
      String loteId, ManualReadingDraft lectura) async {
    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      final creada = await _batchRepo.registrarLecturaManual(loteId, lectura);
      await cargarPares(loteId);
      await refrescarLote(loteId);
      return creada;
    } catch (e) {
      _error = apiErrorMessage(e);
      return null;
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
