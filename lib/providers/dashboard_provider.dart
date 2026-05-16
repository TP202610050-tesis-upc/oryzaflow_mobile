import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/batch_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/node_model.dart';
import '../models/silo_model.dart';
import '../repositories/i_alert_repository.dart';
import '../repositories/i_batch_repository.dart';
import '../repositories/i_node_repository.dart';
import '../repositories/i_silo_repository.dart';
import '../core/enums/node_status.dart';

class DashboardProvider extends ChangeNotifier {
  final INodeRepository _nodeRepo;
  final IBatchRepository _batchRepo;
  final IAlertRepository _alertRepo;
  final ISiloRepository _siloRepo;

  DashboardProvider(
      this._nodeRepo, this._batchRepo, this._alertRepo, this._siloRepo);

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
      final resultados = await Future.wait([
        _nodeRepo.obtenerNodos(),
        _batchRepo.obtenerLotesActivos(),
        _alertRepo.obtenerAlertas(),
        _siloRepo.obtenerSilos(),
      ]);

      _nodos = resultados[0] as List<NodeModel>;
      _lotesActivos = resultados[1] as List<BatchModel>;
      final todasAlertas = resultados[2] as List<AlertModel>;
      _silos = resultados[3] as List<SiloModel>;

      _alertasRecientes = todasAlertas.take(5).toList();

      final nodosActivos =
          _nodos.where((n) => n.estado == NodeStatus.activo).length;
      final alertasNoLeidas =
          todasAlertas.where((a) => !a.leida).length;
      final kgHoy = _lotesActivos.fold<double>(0, (s, l) => s + l.pesoKg);
      final tempProm = nodosActivos == 0
          ? 0.0
          : _nodos
                  .where((n) => n.estado == NodeStatus.activo)
                  .fold<double>(0, (s, n) => s + n.temperatura) /
              nodosActivos;
      final hgProm = nodosActivos == 0
          ? 0.0
          : _nodos
                  .where((n) => n.estado == NodeStatus.activo)
                  .fold<double>(0, (s, n) => s + n.humedadGrano) /
              nodosActivos;
      final silosDisp =
          _silos.where((s) => s.estado == SiloStatus.disponible).length;

      _resumen = DashboardSummaryModel(
        nodosActivos: nodosActivos,
        totalNodos: _nodos.length,
        lotesEnProceso: _lotesActivos.length,
        alertasNoLeidas: alertasNoLeidas,
        totalKgProcesadosHoy: kgHoy,
        humedadGranoPromedio: hgProm,
        temperaturaPromedio: tempProm,
        silosDisponibles: silosDisp,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
