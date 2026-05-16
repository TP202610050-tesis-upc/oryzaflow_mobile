import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../models/kpi_model.dart';
import '../models/silo_model.dart';
import '../models/variety_model.dart';
import '../repositories/i_report_repository.dart';
import '../repositories/i_silo_repository.dart';
import '../repositories/i_variety_repository.dart';

class ReportProvider extends ChangeNotifier {
  final IReportRepository _reportRepo;
  final ISiloRepository _siloRepo;
  final IVarietyRepository _varietyRepo;

  ReportProvider(this._reportRepo, this._siloRepo, this._varietyRepo);

  List<BatchModel> _historial = [];
  KpiModel? _kpis;
  List<SiloModel> _silos = [];
  List<VarietyModel> _variedades = [];
  DateTime _desde = DateTime.now().subtract(const Duration(days: 30));
  DateTime _hasta = DateTime.now();
  String? _siloFiltro;
  String? _variedadFiltro;
  bool _cargando = false;
  bool _exportando = false;
  String? _error;
  String? _rutaExportada;

  List<BatchModel> get historial => _historial;
  KpiModel? get kpis => _kpis;
  List<SiloModel> get silos => _silos;
  List<VarietyModel> get variedades => _variedades;
  DateTime get desde => _desde;
  DateTime get hasta => _hasta;
  bool get estaCargando => _cargando;
  bool get estaExportando => _exportando;
  String? get error => _error;
  String? get rutaExportada => _rutaExportada;

  void setFiltroFechas(DateTime desde, DateTime hasta) {
    _desde = desde;
    _hasta = hasta;
    notifyListeners();
  }

  Future<void> cargarHistorial() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final r = await Future.wait([
        _reportRepo.obtenerHistorialSecados(
            desde: _desde, hasta: _hasta,
            siloId: _siloFiltro, variedadId: _variedadFiltro),
        _siloRepo.obtenerSilos(),
        _varietyRepo.obtenerVariedades(),
      ]);
      _historial = r[0] as List<BatchModel>;
      _silos = r[1] as List<SiloModel>;
      _variedades = r[2] as List<VarietyModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarKpis() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _kpis = await _reportRepo.obtenerKpis(desde: _desde, hasta: _hasta);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> exportar(String formato) async {
    _exportando = true;
    _rutaExportada = null;
    _error = null;
    notifyListeners();
    try {
      _rutaExportada = await _reportRepo.exportarReporte(
          desde: _desde, hasta: _hasta, formato: formato);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _exportando = false;
      notifyListeners();
    }
  }
}
