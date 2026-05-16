import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [periodoDesde, periodoHasta, totalKgProcesados];
}
