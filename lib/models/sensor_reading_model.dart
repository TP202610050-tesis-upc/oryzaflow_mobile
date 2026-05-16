import 'package:equatable/equatable.dart';

class SensorReadingModel extends Equatable {
  final DateTime timestamp;
  final double temperatura;
  final double humedad;
  final double flujoAire;
  final double humedadGrano;

  const SensorReadingModel({
    required this.timestamp,
    required this.temperatura,
    required this.humedad,
    required this.flujoAire,
    required this.humedadGrano,
  });

  @override
  List<Object?> get props => [timestamp];
}
