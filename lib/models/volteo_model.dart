import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';
import 'pending_event_model.dart';

/// Método de volteo (#45). El backend serializa en MAYÚSCULAS (MANUAL/ACTUADOR);
/// `fromJson` normaliza a minúsculas antes de `byName`. En el entorno real es siempre manual.
enum MetodoVolteo { manual, actuador }

/// Registro de un volteo del grano para un lote (HU-24). Lo devuelve `POST /batches/{id}/flip`
/// y `GET /batches/{id}/flips`. `pendiente` = registrado sin señal y aún no sincronizado.
class VolteoModel extends Equatable {
  final String id;
  final String loteId;
  final MetodoVolteo metodo;
  final DateTime timestamp;
  final bool pendiente;

  const VolteoModel({
    required this.id,
    required this.loteId,
    required this.metodo,
    required this.timestamp,
    this.pendiente = false,
  });

  factory VolteoModel.fromJson(Map<String, dynamic> json) => VolteoModel(
        id: json['id'].toString(),
        loteId: json['loteId'].toString(),
        metodo: MetodoVolteo.values
            .byName((json['metodo'] as String? ?? 'manual').toLowerCase()),
        timestamp: parseFecha(json['timestamp']),
      );

  /// Volteo en cola (HU-010, CA-010-02): se muestra con su hora mientras se sincroniza.
  factory VolteoModel.local(PendingEvent e) => VolteoModel(
        id: 'local-${e.id}',
        loteId: e.loteId,
        metodo: MetodoVolteo.manual,
        timestamp: e.ts.toLocal(),
        pendiente: true,
      );

  @override
  List<Object?> get props => [id, loteId, metodo, timestamp];
}
