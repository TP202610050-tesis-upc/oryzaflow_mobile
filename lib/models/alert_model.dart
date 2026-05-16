import 'package:equatable/equatable.dart';
import '../core/enums/alert_severity.dart';

class AlertModel extends Equatable {
  final String id;
  final String nodoId;
  final String nodoNombre;
  final String mensaje;
  final AlertSeverity severidad;
  final DateTime timestamp;
  final bool leida;
  final String? loteId;

  const AlertModel({
    required this.id,
    required this.nodoId,
    required this.nodoNombre,
    required this.mensaje,
    required this.severidad,
    required this.timestamp,
    required this.leida,
    this.loteId,
  });

  AlertModel copyWith({bool? leida}) => AlertModel(
        id: id,
        nodoId: nodoId,
        nodoNombre: nodoNombre,
        mensaje: mensaje,
        severidad: severidad,
        timestamp: timestamp,
        leida: leida ?? this.leida,
        loteId: loteId,
      );

  @override
  List<Object?> get props => [id, leida];
}
