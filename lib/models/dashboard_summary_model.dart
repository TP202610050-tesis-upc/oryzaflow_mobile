import 'package:equatable/equatable.dart';

class DashboardSummaryModel extends Equatable {
  final int nodosActivos;
  final int totalNodos;
  final int lotesEnProceso;
  final int alertasNoLeidas;
  final double totalKgProcesadosHoy;
  final double humedadGranoPromedio;
  final double temperaturaPromedio;
  final int silosDisponibles;

  const DashboardSummaryModel({
    required this.nodosActivos,
    required this.totalNodos,
    required this.lotesEnProceso,
    required this.alertasNoLeidas,
    required this.totalKgProcesadosHoy,
    required this.humedadGranoPromedio,
    required this.temperaturaPromedio,
    required this.silosDisponibles,
  });

  @override
  List<Object?> get props => [
        nodosActivos,
        lotesEnProceso,
        alertasNoLeidas,
        totalKgProcesadosHoy,
      ];
}
