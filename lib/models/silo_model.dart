import 'package:equatable/equatable.dart';

enum SiloStatus { disponible, ocupado, mantenimiento }

extension SiloStatusExtension on SiloStatus {
  String get displayName => switch (this) {
        SiloStatus.disponible => 'Disponible',
        SiloStatus.ocupado => 'Ocupado',
        SiloStatus.mantenimiento => 'Mantenimiento',
      };
}

class SiloModel extends Equatable {
  final String id;
  final String nombre;
  final String ubicacion;
  final double capacidadToneladas;
  final SiloStatus estado;
  final String? loteActivoId;
  final double? ocupacionActualToneladas;
  final String? serialEsp32;

  const SiloModel({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.capacidadToneladas,
    required this.estado,
    this.loteActivoId,
    this.ocupacionActualToneladas,
    this.serialEsp32,
  });

  double get porcentajeOcupacion =>
      ocupacionActualToneladas != null && capacidadToneladas > 0
          ? (ocupacionActualToneladas! / capacidadToneladas * 100).clamp(0, 100)
          : 0;

  SiloModel copyWith({
    String? nombre,
    String? ubicacion,
    double? capacidadToneladas,
    SiloStatus? estado,
    String? loteActivoId,
    double? ocupacionActualToneladas,
    String? serialEsp32,
  }) =>
      SiloModel(
        id: id,
        nombre: nombre ?? this.nombre,
        ubicacion: ubicacion ?? this.ubicacion,
        capacidadToneladas: capacidadToneladas ?? this.capacidadToneladas,
        estado: estado ?? this.estado,
        loteActivoId: loteActivoId ?? this.loteActivoId,
        ocupacionActualToneladas:
            ocupacionActualToneladas ?? this.ocupacionActualToneladas,
        serialEsp32: serialEsp32 ?? this.serialEsp32,
      );

  @override
  List<Object?> get props => [id, estado, ocupacionActualToneladas];
}
