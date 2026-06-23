import '../models/dashboard_summary_model.dart';

abstract class IDashboardRepository {
  Future<DashboardSummaryModel> obtenerResumen();
}
