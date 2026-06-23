import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

class SensorReadingModel extends Equatable {
  final DateTime timestamp;
  final double temperatura;
  final double humedad;
  final double humedadGrano;
  // Derivados calculados en el edge (tipo B; nullables cuando no hay lote activo).
  final double? humedadEquilibrio;
  final double? razonHumedad;
  final double? tasaSecado;
  final double? tiempoRestanteHoras;
  final bool lluvia;

  const SensorReadingModel({
    required this.timestamp,
    required this.temperatura,
    required this.humedad,
    required this.humedadGrano,
    this.humedadEquilibrio,
    this.razonHumedad,
    this.tasaSecado,
    this.tiempoRestanteHoras,
    this.lluvia = false,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) =>
      SensorReadingModel(
        timestamp: parseFecha(json['timestamp']),
        temperatura: parseDouble(json['temperatura']),
        humedad: parseDouble(json['humedad']),
        humedadGrano: parseDouble(json['humedadGrano']),
        humedadEquilibrio: parseDoubleNullable(json['humedadEquilibrio']),
        razonHumedad: parseDoubleNullable(json['razonHumedad']),
        tasaSecado: parseDoubleNullable(json['tasaSecado']),
        tiempoRestanteHoras: parseDoubleNullable(json['tiempoRestanteHoras']),
        lluvia: json['lluvia'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [timestamp];
}
