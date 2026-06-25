import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

enum SiloStatus { disponible, ocupado, mantenimiento, deBaja }

extension SiloStatusExtension on SiloStatus {
  String get displayName => switch (this) {
        SiloStatus.disponible => 'Disponible',
        SiloStatus.ocupado => 'Ocupado',
        SiloStatus.mantenimiento => 'Mantenimiento',
        SiloStatus.deBaja => 'De baja',
      };
}

class SiloModel extends Equatable {
  final String id;
  final String nombre;
  final String ubicacion;
  final double superficie;
  final double capacidadKg;
  final SiloStatus estado;
  final String? loteActivoId;
  final double? ocupacionActualKg;
  final String? serialEsp32;

  const SiloModel({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.capacidadKg,
    required this.estado,
    this.superficie = 0,
    this.loteActivoId,
    this.ocupacionActualKg,
    this.serialEsp32,
  });

  double get porcentajeOcupacion =>
      ocupacionActualKg != null && capacidadKg > 0
          ? (ocupacionActualKg! / capacidadKg * 100).clamp(0, 100)
          : 0;

  factory SiloModel.fromJson(Map<String, dynamic> json) => SiloModel(
        id: json['id'].toString(),
        nombre: json['nombre'] as String? ?? '',
        ubicacion: json['ubicacion'] as String? ?? '',
        superficie: parseDouble(json['superficie']),
        capacidadKg: parseDouble(json['capacidadKg']),
        estado: siloStatusFromApi(json['estado'] as String),
        loteActivoId: json['loteActivoId']?.toString(),
        ocupacionActualKg: parseDoubleNullable(json['ocupacionActualKg']),
        serialEsp32: json['serialEsp32'] as String?,
      );

  Map<String, dynamic> toCreateJson() => {
        'nombre': nombre,
        'ubicacion': ubicacion,
        'superficie': superficie,
        'capacidadKg': capacidadKg,
      };

  Map<String, dynamic> toUpdateJson() => {
        'nombre': nombre,
        'ubicacion': ubicacion,
        'superficie': superficie,
        'capacidadKg': capacidadKg,
        'estado': siloStatusToApi(estado),
      };

  SiloModel copyWith({
    String? nombre,
    String? ubicacion,
    double? superficie,
    double? capacidadKg,
    SiloStatus? estado,
    String? loteActivoId,
    double? ocupacionActualKg,
    String? serialEsp32,
  }) =>
      SiloModel(
        id: id,
        nombre: nombre ?? this.nombre,
        ubicacion: ubicacion ?? this.ubicacion,
        superficie: superficie ?? this.superficie,
        capacidadKg: capacidadKg ?? this.capacidadKg,
        estado: estado ?? this.estado,
        loteActivoId: loteActivoId ?? this.loteActivoId,
        ocupacionActualKg: ocupacionActualKg ?? this.ocupacionActualKg,
        serialEsp32: serialEsp32 ?? this.serialEsp32,
      );

  @override
  List<Object?> get props => [id, estado, ocupacionActualKg];
}
