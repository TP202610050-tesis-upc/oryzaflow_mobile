import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Motivo con el que la app cierra el segmento diario ("cubrir" el lote, F3). RECOJO lo decide
/// el flujo de detener, no este enum.
enum MotivoCierre { noche, lluvia }

extension MotivoCierreX on MotivoCierre {
  String get api => switch (this) {
        MotivoCierre.noche => 'NOCHE',
        MotivoCierre.lluvia => 'LLUVIA',
      };

  String get displayName => switch (this) {
        MotivoCierre.noche => 'Noche (sereno)',
        MotivoCierre.lluvia => 'Lluvia',
      };
}

MotivoCierre motivoCierreFromApi(String? s) =>
    s == 'LLUVIA' ? MotivoCierre.lluvia : MotivoCierre.noche;

/// Segmento diario de secado (DryingSegmentResource). Tolerante: solo `id` y `batchId` son obligatorios.
class SegmentModel extends Equatable {
  final String id;
  final String loteId;
  final int numero;
  final DateTime inicioTs;
  final DateTime? finTs;
  final double? m0;
  final DateTime? horaDescubrir;
  final String? observaciones;
  /// NOCHE | LLUVIA | RECOJO | CANCELACION (tal como lo manda el backend).
  final String? motivoCierre;
  final bool abierto;

  const SegmentModel({
    required this.id,
    required this.loteId,
    required this.numero,
    required this.inicioTs,
    this.finTs,
    this.m0,
    this.horaDescubrir,
    this.observaciones,
    this.motivoCierre,
    this.abierto = false,
  });

  factory SegmentModel.fromJson(Map<String, dynamic> json) => SegmentModel(
        id: json['id'].toString(),
        loteId: (json['batchId'] ?? json['loteId']).toString(),
        numero: (json['numero'] as num?)?.toInt() ?? 0,
        inicioTs: parseFecha(json['inicioTs']),
        finTs: parseFechaNullable(json['finTs']),
        m0: parseDoubleNullable(json['m0Segmento'] ?? json['m0']),
        horaDescubrir: parseFechaNullable(json['horaDescubrir']),
        observaciones: json['observaciones'] as String?,
        motivoCierre: json['motivoCierre'] as String?,
        abierto: json['abierto'] as bool? ?? json['finTs'] == null,
      );

  @override
  List<Object?> get props => [id, loteId, numero, inicioTs, finTs, abierto];
}
