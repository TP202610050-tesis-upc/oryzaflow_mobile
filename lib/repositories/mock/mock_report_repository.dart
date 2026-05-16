import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/enums/batch_status.dart';
import '../../models/batch_model.dart';
import '../../models/kpi_model.dart';
import '../i_report_repository.dart';
import 'mock_data.dart';

class MockReportRepository implements IReportRepository {
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<List<BatchModel>> obtenerHistorialSecados({
    DateTime? desde,
    DateTime? hasta,
    String? siloId,
    String? variedadId,
  }) async {
    await Future.delayed(_delay);
    var result = MockData.lotes
        .where((l) => l.estado == BatchStatus.completado || l.estado == BatchStatus.cancelado)
        .toList();
    if (desde != null) {
      result = result.where((l) => l.fechaIngreso.isAfter(desde)).toList();
    }
    if (hasta != null) {
      result = result.where((l) => l.fechaIngreso.isBefore(hasta)).toList();
    }
    if (siloId != null) {
      result = result.where((l) => l.siloId == siloId).toList();
    }
    if (variedadId != null) {
      result = result.where((l) => l.variedadId == variedadId).toList();
    }
    return result;
  }

  @override
  Future<KpiModel> obtenerKpis({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future.delayed(_delay);
    return MockData.kpisMes;
  }

  @override
  Future<String> exportarReporte({
    required DateTime desde,
    required DateTime hasta,
    required String formato,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final lotes = MockData.lotes
        .where((l) =>
            !l.fechaIngreso.isBefore(desde) && !l.fechaIngreso.isAfter(hasta))
        .toList();

    final df = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer();
    buf.writeln(
        'Codigo,Silo,Variedad,Estado,Peso(kg),Humedad Inicial(%),Humedad Final(%),Fecha Ingreso,Fecha Inicio,Fecha Fin,Operador');
    for (final l in lotes) {
      buf.writeln([
        l.codigo,
        '"${l.siloNombre}"',
        '"${l.variedadNombre}"',
        l.estado.name,
        l.pesoKg.toStringAsFixed(1),
        l.humedadInicial.toStringAsFixed(1),
        l.humedadFinal?.toStringAsFixed(1) ?? '',
        df.format(l.fechaIngreso),
        l.fechaInicio != null ? df.format(l.fechaInicio!) : '',
        l.fechaFin != null ? df.format(l.fechaFin!) : '',
        '"${l.operadorNombre}"',
      ].join(','));
    }

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final ext = formato.toLowerCase();
    final file = File('${dir.path}/reporte_oryzaflow_$ts.$ext');
    await file.writeAsString(buf.toString());
    return file.path;
  }
}
