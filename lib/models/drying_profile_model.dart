import 'package:equatable/equatable.dart';

class DryingProfileModel extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double temperaturaObjetivo;
  final double humedadObjetivo;
  final double flujoAireObjetivo;
  final double humedadGranoObjetivo;
  final int duracionEstimadaMinutos;
  final DateTime creadoEn;
  final String creadoPorId;

  const DryingProfileModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.temperaturaObjetivo,
    required this.humedadObjetivo,
    required this.flujoAireObjetivo,
    required this.humedadGranoObjetivo,
    required this.duracionEstimadaMinutos,
    required this.creadoEn,
    required this.creadoPorId,
  });

  DryingProfileModel copyWith({
    String? nombre,
    String? descripcion,
    double? temperaturaObjetivo,
    double? humedadObjetivo,
    double? flujoAireObjetivo,
    double? humedadGranoObjetivo,
    int? duracionEstimadaMinutos,
  }) =>
      DryingProfileModel(
        id: id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        temperaturaObjetivo: temperaturaObjetivo ?? this.temperaturaObjetivo,
        humedadObjetivo: humedadObjetivo ?? this.humedadObjetivo,
        flujoAireObjetivo: flujoAireObjetivo ?? this.flujoAireObjetivo,
        humedadGranoObjetivo:
            humedadGranoObjetivo ?? this.humedadGranoObjetivo,
        duracionEstimadaMinutos:
            duracionEstimadaMinutos ?? this.duracionEstimadaMinutos,
        creadoEn: creadoEn,
        creadoPorId: creadoPorId,
      );

  @override
  List<Object?> get props => [id, nombre];
}
