import '../../core/network/api_client.dart';
import '../../models/alert_model.dart';
import '../i_alert_repository.dart';

/// Alertas reales (BC5). El borrado es soft (descarte) en el backend; el "deshacer" del
/// swipe se resuelve en el cliente difiriendo el DELETE (ver AlertProvider, §7.4), por lo
/// que [restaurarAlerta] no tiene endpoint y es un no-op.
class RealAlertRepository implements IAlertRepository {
  final ApiClient _api;

  RealAlertRepository(this._api);

  List<AlertModel> _parse(dynamic data) => (data as List<dynamic>)
      .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<AlertModel>> obtenerAlertas() async {
    final res = await _api.dio.get('/alerts');
    return _parse(res.data);
  }

  @override
  Future<List<AlertModel>> obtenerAlertasNoLeidas() async {
    final res = await _api.dio.get('/alerts', queryParameters: {'leida': 'false'});
    return _parse(res.data);
  }

  @override
  Future<AlertModel> marcarComoLeida(String id) async {
    final res = await _api.dio.patch('/alerts/$id/read');
    return AlertModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    await _api.dio.patch('/alerts/read-all');
  }

  @override
  Future<void> eliminarAlerta(String id) async {
    await _api.dio.delete('/alerts/$id');
  }

  @override
  Future<void> registrarTokenDispositivo(String token, {String plataforma = 'android'}) async {
    await _api.dio.post('/notifications/device-tokens',
        data: {'token': token, 'plataforma': plataforma});
  }

  @override
  Future<void> eliminarTokenDispositivo(String token) async {
    await _api.dio.delete('/notifications/device-tokens/${Uri.encodeComponent(token)}');
  }

  @override
  Future<void> restaurarAlerta(AlertModel alerta) async {
    // El backend no expone restore (el descarte es soft, conserva historial). El undo del
    // swipe se maneja en el cliente difiriendo el DELETE.
  }
}
