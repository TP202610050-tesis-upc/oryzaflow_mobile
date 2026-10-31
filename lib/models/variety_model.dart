import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

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

  factory VarietyModel.fromJson(Map<String, dynamic> json) => VarietyModel(
        id: json['id'].toString(),
        nombre: json['nombre'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        humedadIngresoMinima: parseDouble(json['humedadIngresoMinima']),
        humedadIngresoMaxima: parseDouble(json['humedadIngresoMaxima']),
        humedadObjetivo: parseDouble(json['humedadObjetivo']),
        temperaturaMaxima: parseDouble(json['temperaturaMaxima']),
        tiempoEstimadoHoras: (json['tiempoEstimadoHoras'] as num?)?.toInt() ?? 0,
        activo: json['activo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'humedadIngresoMinima': humedadIngresoMinima,
        'humedadIngresoMaxima': humedadIngresoMaxima,
        'humedadObjetivo': humedadObjetivo,
        'temperaturaMaxima': temperaturaMaxima,
        'tiempoEstimadoHoras': tiempoEstimadoHoras,
      };

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
