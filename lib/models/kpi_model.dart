import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

class KpiModel extends Equatable {
  final double eficienciaEnergetica;
  final double totalKgProcesados;
  final double tiempoPromedioHoras;
  final double tasaExitoPercent;
  final int totalLotesCompletados;
  final int totalLotesCancelados;
  final double humedadPromedioFinal;
  final double reduccionHumedadPromedio;
  final DateTime periodoDesde;
  final DateTime periodoHasta;

  const KpiModel({
    required this.eficienciaEnergetica,
    required this.totalKgProcesados,
    required this.tiempoPromedioHoras,
    required this.tasaExitoPercent,
    required this.totalLotesCompletados,
    required this.totalLotesCancelados,
    required this.humedadPromedioFinal,
    required this.reduccionHumedadPromedio,
    required this.periodoDesde,
    required this.periodoHasta,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) => KpiModel(
        eficienciaEnergetica: parseDouble(json['eficienciaEnergetica']),
        totalKgProcesados: parseDouble(json['totalKgProcesados']),
        tiempoPromedioHoras: parseDouble(json['tiempoPromedioHoras']),
        tasaExitoPercent: parseDouble(json['tasaExitoPercent']),
        totalLotesCompletados:
            (json['totalLotesCompletados'] as num?)?.toInt() ?? 0,
        totalLotesCancelados:
            (json['totalLotesCancelados'] as num?)?.toInt() ?? 0,
        humedadPromedioFinal: parseDouble(json['humedadPromedioFinal']),
        reduccionHumedadPromedio: parseDouble(json['reduccionHumedadPromedio']),
        periodoDesde: parseFecha(json['periodoDesde']),
        periodoHasta: parseFecha(json['periodoHasta']),
      );

  @override
  List<Object?> get props => [periodoDesde, periodoHasta, totalKgProcesados];
}
