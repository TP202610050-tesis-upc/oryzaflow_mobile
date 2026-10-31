import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

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

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        nodosActivos: (json['nodosActivos'] as num?)?.toInt() ?? 0,
        totalNodos: (json['totalNodos'] as num?)?.toInt() ?? 0,
        lotesEnProceso: (json['lotesEnProceso'] as num?)?.toInt() ?? 0,
        alertasNoLeidas: (json['alertasNoLeidas'] as num?)?.toInt() ?? 0,
        totalKgProcesadosHoy: parseDouble(json['totalKgProcesadosHoy']),
        humedadGranoPromedio: parseDouble(json['humedadGranoPromedio']),
        temperaturaPromedio: parseDouble(json['temperaturaPromedio']),
        silosDisponibles: (json['silosDisponibles'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [
        nodosActivos,
        lotesEnProceso,
        alertasNoLeidas,
        totalKgProcesadosHoy,
      ];
}
