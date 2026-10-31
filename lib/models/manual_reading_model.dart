import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Mantada instrumentada de la que se toma la muestra (protocolo anexo B).
enum Mantada { m1, m2, m3 }

extension MantadaExtension on Mantada {
  String get api => switch (this) {
        Mantada.m1 => 'M1',
        Mantada.m2 => 'M2',
        Mantada.m3 => 'M3',
      };
  String get displayName => api;
}

Mantada mantadaFromApi(String? s) => switch (s) {
      'M2' => Mantada.m2,
      'M3' => Mantada.m3,
      _ => Mantada.m1,
    };

/// Lectura manual del medidor PM-410 (F7, HU-013): tres lecturas de la misma muestra y su promedio (% b.h.).
/// El backend valida promedio 5–40 y rango entre lecturas ≤ 0,5 pp (si no, exige `valida=false` con causa).
class ManualReadingModel extends Equatable {
  final String id;
  final String batchId;
  final int? segmentoNumero;
  final Mantada mantada;
  final DateTime ts;
  final double lectura1;
  final double lectura2;
  final double lectura3;
  final double promedio;
  final double rango;
  final double? temperaturaGrano;
  final bool valida;
  final String? causaInvalidez;
  final String? observador;

  const ManualReadingModel({
    required this.id,
    required this.batchId,
    required this.mantada,
    required this.ts,
    required this.lectura1,
    required this.lectura2,
    required this.lectura3,
    required this.promedio,
    required this.rango,
    required this.valida,
    this.segmentoNumero,
    this.temperaturaGrano,
    this.causaInvalidez,
    this.observador,
  });

  factory ManualReadingModel.fromJson(Map<String, dynamic> json) =>
      ManualReadingModel(
        id: json['id'].toString(),
        batchId: json['batchId'].toString(),
        segmentoNumero: (json['segmentoNumero'] as num?)?.toInt(),
        mantada: mantadaFromApi(json['mantada'] as String?),
        ts: parseFecha(json['ts']),
        lectura1: parseDouble(json['lectura1']),
        lectura2: parseDouble(json['lectura2']),
        lectura3: parseDouble(json['lectura3']),
        promedio: parseDouble(json['promedio']),
        rango: parseDouble(json['rango']),
        temperaturaGrano: parseDoubleNullable(json['temperaturaGrano']),
        valida: json['valida'] as bool? ?? true,
        causaInvalidez: json['causaInvalidez'] as String?,
        observador: json['observador'] as String?,
      );

  @override
  List<Object?> get props => [id];
}

/// Borrador del formulario (POST /batches/{id}/manual-readings). ts null = ahora (lo pone el backend).
class ManualReadingDraft {
  final Mantada mantada;
  final double lectura1;
  final double lectura2;
  final double lectura3;
  final double? temperaturaGrano;
  final DateTime? ts;
  final bool? valida;
  final String? causaInvalidez;

  const ManualReadingDraft({
    required this.mantada,
    required this.lectura1,
    required this.lectura2,
    required this.lectura3,
    this.temperaturaGrano,
    this.ts,
    this.valida,
    this.causaInvalidez,
  });

  double get rango => [lectura1, lectura2, lectura3].reduce((a, b) => a > b ? a : b) -
      [lectura1, lectura2, lectura3].reduce((a, b) => a < b ? a : b);

  Map<String, dynamic> toJson() => {
        'mantada': mantada.api,
        'lectura1': lectura1,
        'lectura2': lectura2,
        'lectura3': lectura3,
        if (temperaturaGrano != null) 'temperaturaGrano': temperaturaGrano,
        if (ts != null) 'ts': ts!.toUtc().toIso8601String(),
        if (valida != null) 'valida': valida,
        if (causaInvalidez != null && causaInvalidez!.isNotEmpty) 'causaInvalidez': causaInvalidez,
      };
}
