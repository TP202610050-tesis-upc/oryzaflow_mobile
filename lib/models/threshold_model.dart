import 'package:equatable/equatable.dart';

class ThresholdModel extends Equatable {
  final String nodoId;
  final double temperaturaMin;
  final double temperaturaMax;
  final double humedadMin;
  final double humedadMax;
  final double flujoAireMin;
  final double flujoAireMax;
  final double humedadGranoMin;
  final double humedadGranoMax;

  const ThresholdModel({
    required this.nodoId,
    required this.temperaturaMin,
    required this.temperaturaMax,
    required this.humedadMin,
    required this.humedadMax,
    required this.flujoAireMin,
    required this.flujoAireMax,
    required this.humedadGranoMin,
    required this.humedadGranoMax,
  });

  ThresholdModel copyWith({
    double? temperaturaMin,
    double? temperaturaMax,
    double? humedadMin,
    double? humedadMax,
    double? flujoAireMin,
    double? flujoAireMax,
    double? humedadGranoMin,
    double? humedadGranoMax,
  }) =>
      ThresholdModel(
        nodoId: nodoId,
        temperaturaMin: temperaturaMin ?? this.temperaturaMin,
        temperaturaMax: temperaturaMax ?? this.temperaturaMax,
        humedadMin: humedadMin ?? this.humedadMin,
        humedadMax: humedadMax ?? this.humedadMax,
        flujoAireMin: flujoAireMin ?? this.flujoAireMin,
        flujoAireMax: flujoAireMax ?? this.flujoAireMax,
        humedadGranoMin: humedadGranoMin ?? this.humedadGranoMin,
        humedadGranoMax: humedadGranoMax ?? this.humedadGranoMax,
      );

  @override
  List<Object?> get props => [nodoId];
}
