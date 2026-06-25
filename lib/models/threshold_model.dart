import 'package:equatable/equatable.dart';

/// Umbrales por nodo (HU-21/22). El backend aún NO expone este recurso (#43-44 pendientes);
/// hoy se sirve como stub local con valores por defecto. Ver RealNodeRepository.
class ThresholdModel extends Equatable {
  final String nodoId;
  final double temperaturaMin;
  final double temperaturaMax;
  final double humedadMin;
  final double humedadMax;
  final double humedadGranoMin;
  final double humedadGranoMax;

  const ThresholdModel({
    required this.nodoId,
    required this.temperaturaMin,
    required this.temperaturaMax,
    required this.humedadMin,
    required this.humedadMax,
    required this.humedadGranoMin,
    required this.humedadGranoMax,
  });

  ThresholdModel copyWith({
    double? temperaturaMin,
    double? temperaturaMax,
    double? humedadMin,
    double? humedadMax,
    double? humedadGranoMin,
    double? humedadGranoMax,
  }) =>
      ThresholdModel(
        nodoId: nodoId,
        temperaturaMin: temperaturaMin ?? this.temperaturaMin,
        temperaturaMax: temperaturaMax ?? this.temperaturaMax,
        humedadMin: humedadMin ?? this.humedadMin,
        humedadMax: humedadMax ?? this.humedadMax,
        humedadGranoMin: humedadGranoMin ?? this.humedadGranoMin,
        humedadGranoMax: humedadGranoMax ?? this.humedadGranoMax,
      );

  @override
  List<Object?> get props => [nodoId];
}
