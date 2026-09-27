import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Estimación vigente del lote (HU-001/HU-003), calculada por el backend a partir de la última telemetría con
/// humedad de grano del nodo. La antigüedad (`desactualizada`) y `noLlegaHoy` los decide el backend con la
/// misma regla que usa el motor de alertas; la app solo los muestra.
class BatchEstimationModel extends Equatable {
  final DateTime ts;
  final double? humedadGrano;
  final double? humedadEquilibrio;
  final double? razonHumedad;
  final double? tasaSecado;
  final double? tiempoRestanteHoras;
  final int? segmento;
  final int intervaloSegundos;
  final int umbralDesactualizadoSegundos;
  final bool desactualizada;
  final DateTime? finEstimado;
  final bool noLlegaHoy;
  final String finJornada;

  const BatchEstimationModel({
    required this.ts,
    required this.intervaloSegundos,
    required this.umbralDesactualizadoSegundos,
    required this.desactualizada,
    required this.noLlegaHoy,
    required this.finJornada,
    this.humedadGrano,
    this.humedadEquilibrio,
    this.razonHumedad,
    this.tasaSecado,
    this.tiempoRestanteHoras,
    this.segmento,
    this.finEstimado,
  });

  factory BatchEstimationModel.fromJson(Map<String, dynamic> json) =>
      BatchEstimationModel(
        ts: parseFecha(json['ts']),
        humedadGrano: parseDoubleNullable(json['humedadGrano']),
        humedadEquilibrio: parseDoubleNullable(json['humedadEquilibrio']),
        razonHumedad: parseDoubleNullable(json['razonHumedad']),
        tasaSecado: parseDoubleNullable(json['tasaSecado']),
        tiempoRestanteHoras: parseDoubleNullable(json['tiempoRestanteHoras']),
        segmento: (json['segmento'] as num?)?.toInt(),
        intervaloSegundos: (json['intervaloSegundos'] as num?)?.toInt() ?? 300,
        umbralDesactualizadoSegundos:
            (json['umbralDesactualizadoSegundos'] as num?)?.toInt() ?? 600,
        desactualizada: json['desactualizada'] as bool? ?? false,
        finEstimado: parseFechaNullable(json['finEstimado']),
        noLlegaHoy: json['noLlegaHoy'] as bool? ?? false,
        finJornada: json['finJornada'] as String? ?? '18:00',
      );

  /// te > 0 → hay una proyección de fin de secado.
  bool get tieneProyeccion =>
      tiempoRestanteHoras != null && tiempoRestanteHoras! > 0 && finEstimado != null;

  /// te == 0 con la humedad por encima de la meta significa "meta inviable con el aire actual" (§7.8); el
  /// backend lo señala con la alerta de FACTIBILIDAD. Aquí solo se distingue "sin proyección".
  Duration? get restante => tieneProyeccion
      ? Duration(minutes: (tiempoRestanteHoras! * 60).round())
      : null;

  @override
  List<Object?> get props => [ts, humedadGrano, desactualizada, noLlegaHoy];
}
