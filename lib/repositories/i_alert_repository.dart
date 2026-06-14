import '../models/alert_model.dart';

abstract class IAlertRepository {
  Future<List<AlertModel>> obtenerAlertas();
  Future<List<AlertModel>> obtenerAlertasNoLeidas();
  Future<AlertModel> marcarComoLeida(String id);
  Future<void> marcarTodasComoLeidas();
  Future<void> eliminarAlerta(String id);
  Future<void> restaurarAlerta(AlertModel alerta);
}
