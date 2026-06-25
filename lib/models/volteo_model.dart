import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

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

  factory VolteoModel.fromJson(Map<String, dynamic> json) => VolteoModel(
        id: json['id'].toString(),
        nodoId: json['nodoId'].toString(),
        metodo: MetodoVolteo.values.byName(json['metodo'] as String? ?? 'manual'),
        timestamp: parseFecha(json['timestamp']),
      );

  @override
  List<Object?> get props => [id, nodoId, metodo, timestamp];
}
