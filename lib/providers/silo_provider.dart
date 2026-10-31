import 'package:flutter/material.dart';
import '../models/drying_profile_model.dart';
import '../models/silo_model.dart';
import '../models/variety_model.dart';
import '../repositories/i_drying_profile_repository.dart';
import '../repositories/i_silo_repository.dart';
import '../repositories/i_variety_repository.dart';

class SiloProvider extends ChangeNotifier {
  final ISiloRepository _siloRepo;
  final IVarietyRepository _varietyRepo;
  final IDryingProfileRepository _profileRepo;

  SiloProvider(this._siloRepo, this._varietyRepo, this._profileRepo);

  List<SiloModel> _silos = [];
  List<VarietyModel> _variedades = [];
  List<DryingProfileModel> _perfiles = [];
  SiloModel? _siloSeleccionado;
  VarietyModel? _variedadSeleccionada;
  Map<DateTime, List<SiloModel>> _disponibilidad = {};
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  List<SiloModel> get silos => _silos;
  List<VarietyModel> get variedades => _variedades;
  List<DryingProfileModel> get perfiles => _perfiles;
  SiloModel? get siloSeleccionado => _siloSeleccionado;
  VarietyModel? get variedadSeleccionada => _variedadSeleccionada;
  Map<DateTime, List<SiloModel>> get disponibilidad => _disponibilidad;
  bool get estaCargando => _cargando;
  bool get estaGuardando => _guardando;
  String? get error => _error;

  Future<void> cargarTodo() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final r = await Future.wait([
        _siloRepo.obtenerSilos(),
        _varietyRepo.obtenerVariedades(),
        _profileRepo.obtenerPerfiles(),
      ]);
      _silos = List.of(r[0] as List<SiloModel>);
      _variedades = List.of(r[1] as List<VarietyModel>);
      _perfiles = r[2] as List<DryingProfileModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarSilos() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _silos = List.of(await _siloRepo.obtenerSilos());
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarVariedades() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _variedades = List.of(await _varietyRepo.obtenerVariedades());
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarPerfiles() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _perfiles = List.of(await _profileRepo.obtenerPerfiles());
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarDisponibilidad() async {
    _cargando = true;
    notifyListeners();
    try {
      final ahora = DateTime.now();
      _disponibilidad = await _siloRepo.obtenerDisponibilidad(
        desde: ahora,
        hasta: ahora.add(const Duration(days: 14)),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarSilo(SiloModel silo, {required bool esNuevo}) async {
    _guardando = true;
    notifyListeners();
    try {
      if (esNuevo) {
        final nuevo = await _siloRepo.crearSilo(silo);
        _silos.add(nuevo);
      } else {
        final actualizado = await _siloRepo.actualizarSilo(silo);
        final idx = _silos.indexWhere((s) => s.id == actualizado.id);
        if (idx != -1) _silos[idx] = actualizado;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarVariedad(VarietyModel v, {required bool esNueva}) async {
    _guardando = true;
    notifyListeners();
    try {
      if (esNueva) {
        final nuevo = await _varietyRepo.crearVariedad(v);
        _variedades.add(nuevo);
      } else {
        final actualizado = await _varietyRepo.actualizarVariedad(v);
        final idx = _variedades.indexWhere((x) => x.id == actualizado.id);
        if (idx != -1) _variedades[idx] = actualizado;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarPerfil(DryingProfileModel p,
      {required bool esNuevo}) async {
    _guardando = true;
    notifyListeners();
    try {
      if (esNuevo) {
        final nuevo = await _profileRepo.crearPerfil(p);
        _perfiles.add(nuevo);
      } else {
        final actualizado = await _profileRepo.actualizarPerfil(p);
        final idx = _perfiles.indexWhere((x) => x.id == actualizado.id);
        if (idx != -1) _perfiles[idx] = actualizado;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarPerfil(String id) async {
    _guardando = true;
    notifyListeners();
    try {
      await _profileRepo.eliminarPerfil(id);
      _perfiles.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarSilo(String id) async {
    _guardando = true;
    notifyListeners();
    try {
      await _siloRepo.eliminarSilo(id);
      _silos.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarVariedad(String id) async {
    _guardando = true;
    notifyListeners();
    try {
      await _varietyRepo.eliminarVariedad(id);
      _variedades.removeWhere((v) => v.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  void seleccionarSilo(SiloModel? silo) {
    _siloSeleccionado = silo;
    notifyListeners();
  }

  void seleccionarVariedad(VarietyModel? variedad) {
    _variedadSeleccionada = variedad;
    notifyListeners();
  }
}
