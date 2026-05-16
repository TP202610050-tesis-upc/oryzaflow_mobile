import 'package:equatable/equatable.dart';

class VarietyModel extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double humedadIngresoMinima;
  final double humedadIngresoMaxima;
  final double humedadObjetivo;
  final double temperaturaMaxima;
  final int tiempoEstimadoHoras;
  final bool activo;

  const VarietyModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.humedadIngresoMinima,
    required this.humedadIngresoMaxima,
    required this.humedadObjetivo,
    required this.temperaturaMaxima,
    required this.tiempoEstimadoHoras,
    this.activo = true,
  });

  VarietyModel copyWith({
    String? nombre,
    String? descripcion,
    double? humedadIngresoMinima,
    double? humedadIngresoMaxima,
    double? humedadObjetivo,
    double? temperaturaMaxima,
    int? tiempoEstimadoHoras,
    bool? activo,
  }) =>
      VarietyModel(
        id: id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        humedadIngresoMinima:
            humedadIngresoMinima ?? this.humedadIngresoMinima,
        humedadIngresoMaxima:
            humedadIngresoMaxima ?? this.humedadIngresoMaxima,
        humedadObjetivo: humedadObjetivo ?? this.humedadObjetivo,
        temperaturaMaxima: temperaturaMaxima ?? this.temperaturaMaxima,
        tiempoEstimadoHoras:
            tiempoEstimadoHoras ?? this.tiempoEstimadoHoras,
        activo: activo ?? this.activo,
      );

  @override
  List<Object?> get props => [id, nombre, activo];
}
