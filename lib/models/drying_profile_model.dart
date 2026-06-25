import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

class DryingProfileModel extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double temperaturaObjetivo;
  final double humedadObjetivo;
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
    required this.humedadGranoObjetivo,
    required this.duracionEstimadaMinutos,
    required this.creadoEn,
    required this.creadoPorId,
  });

  factory DryingProfileModel.fromJson(Map<String, dynamic> json) =>
      DryingProfileModel(
        id: json['id'].toString(),
        nombre: json['nombre'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        temperaturaObjetivo: parseDouble(json['temperaturaObjetivo']),
        humedadObjetivo: parseDouble(json['humedadObjetivo']),
        humedadGranoObjetivo: parseDouble(json['humedadGranoObjetivo']),
        duracionEstimadaMinutos:
            (json['duracionEstimadaMinutos'] as num?)?.toInt() ?? 0,
        creadoEn: parseFecha(json['createdAt']),
        creadoPorId: json['creadoPorId']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'temperaturaObjetivo': temperaturaObjetivo,
        'humedadObjetivo': humedadObjetivo,
        'humedadGranoObjetivo': humedadGranoObjetivo,
        'duracionEstimadaMinutos': duracionEstimadaMinutos,
      };

  DryingProfileModel copyWith({
    String? nombre,
    String? descripcion,
    double? temperaturaObjetivo,
    double? humedadObjetivo,
    double? humedadGranoObjetivo,
    int? duracionEstimadaMinutos,
  }) =>
      DryingProfileModel(
        id: id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        temperaturaObjetivo: temperaturaObjetivo ?? this.temperaturaObjetivo,
        humedadObjetivo: humedadObjetivo ?? this.humedadObjetivo,
        humedadGranoObjetivo: humedadGranoObjetivo ?? this.humedadGranoObjetivo,
        duracionEstimadaMinutos:
            duracionEstimadaMinutos ?? this.duracionEstimadaMinutos,
        creadoEn: creadoEn,
        creadoPorId: creadoPorId,
      );

  @override
  List<Object?> get props => [id, nombre];
}
