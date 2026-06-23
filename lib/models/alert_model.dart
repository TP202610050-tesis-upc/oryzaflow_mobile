import 'package:equatable/equatable.dart';
import '../core/enums/alert_severity.dart';
import '../core/network/json_mappers.dart';

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

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'].toString(),
        nodoId: json['nodoId'].toString(),
        nodoNombre: json['nodoNombre'] as String? ?? '',
        mensaje: json['mensaje'] as String? ?? '',
        severidad: AlertSeverity.values.byName(json['severidad'] as String),
        timestamp: parseFecha(json['timestamp']),
        leida: json['leida'] as bool? ?? false,
        loteId: json['loteId'] as String?,
      );

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
