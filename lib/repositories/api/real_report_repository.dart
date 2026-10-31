import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/network/api_client.dart';
import '../../models/batch_model.dart';
import '../../models/kpi_model.dart';
import '../i_report_repository.dart';

/// Reportería real (BC6): historial, KPIs y export Excel (descarga binaria).
class RealReportRepository implements IReportRepository {
  final ApiClient _api;

  RealReportRepository(this._api);

  // El backend espera fechas ISO-DATE (yyyy-MM-dd) en estos endpoints.
  String _fecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<BatchModel>> obtenerHistorialSecados({
    DateTime? desde,
    DateTime? hasta,
    String? siloId,
    String? variedadId,
  }) async {
    final res = await _api.dio.get('/reports/history', queryParameters: {
      if (desde != null) 'desde': _fecha(desde),
      if (hasta != null) 'hasta': _fecha(hasta),
      if (siloId != null) 'siloId': siloId,
      if (variedadId != null) 'variedadId': variedadId,
    });
    return (res.data as List<dynamic>)
        .map((e) => BatchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<KpiModel> obtenerKpis({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final res = await _api.dio.get('/analytics/kpis', queryParameters: {
      'desde': _fecha(desde),
      'hasta': _fecha(hasta),
    });
    return KpiModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// Descarga el .xlsx generado por el backend, lo guarda en el dispositivo y devuelve la ruta.
  @override
  Future<String> exportarReporte({
    required DateTime desde,
    required DateTime hasta,
    required String formato,
  }) async {
    final res = await _api.dio.get(
      '/reports/export',
      queryParameters: {
        'desde': _fecha(desde),
        'hasta': _fecha(hasta),
        'formato': formato,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getApplicationDocumentsDirectory();
    final nombre = 'reporte_oryzaflow_${_fecha(desde)}_${_fecha(hasta)}.$formato';
    final file = File('${dir.path}/$nombre');
    await file.writeAsBytes(res.data as List<int>);
    return file.path;
  }
}
