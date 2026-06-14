import 'package:equatable/equatable.dart';

enum MetodoVolteo { manual }

class VolteoModel extends Equatable {
  final String id;
  final String nodoId;
  final MetodoVolteo metodo;
  final DateTime timestamp;

  const VolteoModel({
    required this.id,
    required this.nodoId,
    required this.metodo,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, nodoId, metodo, timestamp];
}
