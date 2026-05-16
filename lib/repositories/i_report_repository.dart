import '../models/kpi_model.dart';
import '../models/batch_model.dart';

abstract class IReportRepository {
  Future<List<BatchModel>> obtenerHistorialSecados({
    DateTime? desde,
    DateTime? hasta,
    String? siloId,
    String? variedadId,
  });
  Future<KpiModel> obtenerKpis({
    required DateTime desde,
    required DateTime hasta,
  });
  Future<String> exportarReporte({
    required DateTime desde,
    required DateTime hasta,
    required String formato,
  });
}
