import '../../models/alert_model.dart';
import '../i_alert_repository.dart';
import 'mock_data.dart';

class MockAlertRepository implements IAlertRepository {
  final List<AlertModel> _alertas = List.from(MockData.alertas);
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<AlertModel>> obtenerAlertas() async {
    await Future.delayed(_delay);
    return List.from(_alertas);
  }

  @override
  Future<List<AlertModel>> obtenerAlertasNoLeidas() async {
    await Future.delayed(_delay);
    return _alertas.where((a) => !a.leida).toList();
  }

  @override
  Future<AlertModel> marcarComoLeida(String id) async {
    await Future.delayed(_delay);
    final idx = _alertas.indexWhere((a) => a.id == id);
    if (idx == -1) throw Exception('Alerta no encontrada');
    final updated = _alertas[idx].copyWith(leida: true);
    _alertas[idx] = updated;
    return updated;
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    await Future.delayed(_delay);
    for (var i = 0; i < _alertas.length; i++) {
      _alertas[i] = _alertas[i].copyWith(leida: true);
    }
  }

  @override
  Future<void> eliminarAlerta(String id) async {
    _alertas.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restaurarAlerta(AlertModel alerta) async {
    if (_alertas.any((a) => a.id == alerta.id)) return;
    _alertas.add(alerta);
    _alertas.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
