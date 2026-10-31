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
  // CA-016-01 (parte mínima): tipo del motor, hora y usuario de atención, minutos emisión → atención.
  final String? tipo;
  final String? batchId;
  final DateTime? leidaEn;
  final String? leidaPor;
  final int? minutosAtencion;
  // CA-015-02 (HU-015): reenvío al supervisor cuando la alerta no se atiende en el tiempo configurado.
  final DateTime? escaladaEn;
  final String? escaladaA; // "SUPERVISOR" | null
  final int? escaladaDispositivos;
  final int? minutosSinAtender; // null cuando ya fue leída

  const AlertModel({
    required this.id,
    required this.nodoId,
    required this.nodoNombre,
    required this.mensaje,
    required this.severidad,
    required this.timestamp,
    required this.leida,
    this.loteId,
    this.tipo,
    this.batchId,
    this.leidaEn,
    this.leidaPor,
    this.minutosAtencion,
    this.escaladaEn,
    this.escaladaA,
    this.escaladaDispositivos,
    this.minutosSinAtender,
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
        tipo: json['tipo'] as String?,
        batchId: json['batchId']?.toString(),
        leidaEn: parseFechaNullable(json['leidaEn']),
        leidaPor: json['leidaPor'] as String?,
        minutosAtencion: (json['minutosAtencion'] as num?)?.toInt(),
        escaladaEn: parseFechaNullable(json['escaladaEn']),
        escaladaA: json['escaladaA'] as String?,
        escaladaDispositivos: (json['escaladaDispositivos'] as num?)?.toInt(),
        minutosSinAtender: (json['minutosSinAtender'] as num?)?.toInt(),
      );

  /// CA-015-02: la alerta fue reenviada al supervisor por no atenderse a tiempo.
  bool get escalada => escaladaEn != null;

  AlertModel copyWith({bool? leida}) => AlertModel(
        id: id,
        nodoId: nodoId,
        nodoNombre: nodoNombre,
        mensaje: mensaje,
        severidad: severidad,
        timestamp: timestamp,
        leida: leida ?? this.leida,
        loteId: loteId,
        tipo: tipo,
        batchId: batchId,
        leidaEn: leidaEn,
        leidaPor: leidaPor,
        minutosAtencion: minutosAtencion,
        escaladaEn: escaladaEn,
        escaladaA: escaladaA,
        escaladaDispositivos: escaladaDispositivos,
        minutosSinAtender: minutosSinAtender,
      );

  @override
  List<Object?> get props => [id, leida, escaladaEn];
}
