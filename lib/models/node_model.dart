import 'package:equatable/equatable.dart';
import '../core/enums/node_status.dart';
import '../core/network/json_mappers.dart';

class NodeModel extends Equatable {
  final String id;
  final String nombre;
  final String ubicacion;
  final NodeStatus estado;
  final double temperatura;
  final double humedad;
  final double humedadGrano;
  final DateTime ultimaActualizacion;
  final String? loteActivoId;
  final String ipAddress;
  final int intervaloEnvioSegundos;

  const NodeModel({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.estado,
    required this.temperatura,
    required this.humedad,
    required this.humedadGrano,
    required this.ultimaActualizacion,
    required this.ipAddress,
    required this.intervaloEnvioSegundos,
    this.loteActivoId,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
        id: json['id'].toString(),
        nombre: json['nombre'] as String? ?? '',
        ubicacion: json['ubicacion'] as String? ?? '',
        estado: nodeStatusFromApi(json['estado'] as String),
        temperatura: parseDouble(json['temperatura']),
        humedad: parseDouble(json['humedad']),
        humedadGrano: parseDouble(json['humedadGrano']),
        ultimaActualizacion: parseFechaNullable(json['ultimaActualizacion']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        loteActivoId: json['loteActivoId']?.toString(),
        ipAddress: json['ipAddress'] as String? ?? '',
        intervaloEnvioSegundos:
            (json['intervaloEnvioSegundos'] as num?)?.toInt() ?? 0,
      );

  NodeModel copyWith({
    String? nombre,
    String? ubicacion,
    NodeStatus? estado,
    double? temperatura,
    double? humedad,
    double? humedadGrano,
    DateTime? ultimaActualizacion,
    String? loteActivoId,
    String? ipAddress,
    int? intervaloEnvioSegundos,
  }) =>
      NodeModel(
        id: id,
        nombre: nombre ?? this.nombre,
        ubicacion: ubicacion ?? this.ubicacion,
        estado: estado ?? this.estado,
        temperatura: temperatura ?? this.temperatura,
        humedad: humedad ?? this.humedad,
        humedadGrano: humedadGrano ?? this.humedadGrano,
        ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
        loteActivoId: loteActivoId ?? this.loteActivoId,
        ipAddress: ipAddress ?? this.ipAddress,
        intervaloEnvioSegundos:
            intervaloEnvioSegundos ?? this.intervaloEnvioSegundos,
      );

  @override
  List<Object?> get props => [
        id, estado, temperatura, humedad, humedadGrano,
        ultimaActualizacion, loteActivoId,
      ];
}
