import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/batch_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/node_model.dart';
import '../models/silo_model.dart';
import '../repositories/i_alert_repository.dart';
import '../repositories/i_batch_repository.dart';
import '../repositories/i_dashboard_repository.dart';
import '../repositories/i_node_repository.dart';
import '../repositories/i_silo_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final IDashboardRepository _dashboardRepo;
  final INodeRepository _nodeRepo;
  final IBatchRepository _batchRepo;
  final IAlertRepository _alertRepo;
  final ISiloRepository _siloRepo;

  DashboardProvider(this._dashboardRepo, this._nodeRepo, this._batchRepo,
      this._alertRepo, this._siloRepo);

  DashboardSummaryModel? _resumen;
  List<NodeModel> _nodos = [];
  List<BatchModel> _lotesActivos = [];
  List<AlertModel> _alertasRecientes = [];
  List<SiloModel> _silos = [];
  bool _cargando = false;
  String? _error;

  DashboardSummaryModel? get resumen => _resumen;
  List<NodeModel> get nodos => _nodos;
  List<BatchModel> get lotesActivos => _lotesActivos;
  List<AlertModel> get alertasRecientes => _alertasRecientes;
  List<SiloModel> get silos => _silos;
  bool get estaCargando => _cargando;
  String? get error => _error;

  Future<void> cargarDashboard() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      // El resumen (KPIs) lo agrega el backend; las listas se traen para mostrarlas.
      final resultados = await Future.wait([
        _dashboardRepo.obtenerResumen(),
        _nodeRepo.obtenerNodos(),
        _batchRepo.obtenerLotesActivos(),
        _alertRepo.obtenerAlertas(),
        _siloRepo.obtenerSilos(),
      ]);

      _resumen = resultados[0] as DashboardSummaryModel;
      _nodos = resultados[1] as List<NodeModel>;
      _lotesActivos = resultados[2] as List<BatchModel>;
      _alertasRecientes = (resultados[3] as List<AlertModel>).take(5).toList();
      _silos = resultados[4] as List<SiloModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
