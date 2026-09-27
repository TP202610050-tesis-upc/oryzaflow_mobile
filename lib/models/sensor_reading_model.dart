import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

class SensorReadingModel extends Equatable {
  final DateTime timestamp;
  final double temperatura;
  final double humedad;
  // Derivados calculados en el edge (tipo B; nulos cuando no hay lote activo — el nodo publica solo ambiente).
  /// Humedad estimada del grano (% b.h.). null = publicación tipo A (sin lote): no se grafica ni se muestra como 0.
  final double? humedadGrano;
  final double? humedadEquilibrio;
  final double? razonHumedad;
  final double? tasaSecado;
  final double? tiempoRestanteHoras;
  final bool lluvia;
  /// Segmento diario (F3) y offsetM vigente (F8), v1.1 del esquema; opcionales.
  final int? segmento;
  final double? offsetM;

  const SensorReadingModel({
    required this.timestamp,
    required this.temperatura,
    required this.humedad,
    this.humedadGrano,
    this.humedadEquilibrio,
    this.razonHumedad,
    this.tasaSecado,
    this.tiempoRestanteHoras,
    this.lluvia = false,
    this.segmento,
    this.offsetM,
  });

  /// true si la publicación trae estimación de grano (lote activo en el nodo).
  bool get tieneEstimacion => humedadGrano != null;

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) =>
      SensorReadingModel(
        timestamp: parseFecha(json['timestamp']),
        temperatura: parseDouble(json['temperatura']),
        humedad: parseDouble(json['humedad']),
        humedadGrano: parseDoubleNullable(json['humedadGrano']),
        humedadEquilibrio: parseDoubleNullable(json['humedadEquilibrio']),
        razonHumedad: parseDoubleNullable(json['razonHumedad']),
        tasaSecado: parseDoubleNullable(json['tasaSecado']),
        tiempoRestanteHoras: parseDoubleNullable(json['tiempoRestanteHoras']),
        lluvia: json['lluvia'] as bool? ?? false,
        segmento: (json['segmento'] as num?)?.toInt(),
        offsetM: parseDoubleNullable(json['offsetM']),
      );

  @override
  List<Object?> get props => [timestamp];
}
