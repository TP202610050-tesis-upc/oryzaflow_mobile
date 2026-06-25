import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Método de volteo (#45). El backend serializa en MAYÚSCULAS (MANUAL/ACTUADOR);
/// `fromJson` normaliza a minúsculas antes de `byName`. En el entorno real es siempre manual.
enum MetodoVolteo { manual, actuador }

/// Registro de un volteo del grano para un lote (HU-24). Lo devuelve `POST /batches/{id}/flip`.
class VolteoModel extends Equatable {
  final String id;
  final String loteId;
  final MetodoVolteo metodo;
  final DateTime timestamp;

  const VolteoModel({
    required this.id,
    required this.loteId,
    required this.metodo,
    required this.timestamp,
  });

  factory VolteoModel.fromJson(Map<String, dynamic> json) => VolteoModel(
        id: json['id'].toString(),
        loteId: json['loteId'].toString(),
        metodo: MetodoVolteo.values
            .byName((json['metodo'] as String? ?? 'manual').toLowerCase()),
        timestamp: parseFecha(json['timestamp']),
      );

  @override
  List<Object?> get props => [id, loteId, metodo, timestamp];
}
