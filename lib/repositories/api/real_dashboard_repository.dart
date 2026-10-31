import '../../core/network/api_client.dart';
import '../../models/dashboard_summary_model.dart';
import '../i_dashboard_repository.dart';

/// Resumen agregado del dashboard (GET /api/v1/dashboard).
class RealDashboardRepository implements IDashboardRepository {
  final ApiClient _api;

  RealDashboardRepository(this._api);

  @override
  Future<DashboardSummaryModel> obtenerResumen() async {
    final res = await _api.dio.get('/dashboard');
    return DashboardSummaryModel.fromJson(res.data as Map<String, dynamic>);
  }
}
