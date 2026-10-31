import '../models/alert_model.dart';

abstract class IAlertRepository {
  Future<List<AlertModel>> obtenerAlertas();
  Future<List<AlertModel>> obtenerAlertasNoLeidas();
  Future<AlertModel> marcarComoLeida(String id);
  Future<void> marcarTodasComoLeidas();
  Future<void> eliminarAlerta(String id);
  Future<void> restaurarAlerta(AlertModel alerta);

  /// Token FCM del dispositivo (HU-012): POST/DELETE /notifications/device-tokens.
  Future<void> registrarTokenDispositivo(String token, {String plataforma = 'android'});
  Future<void> eliminarTokenDispositivo(String token);
}
