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
  /// CA-002-02: el backend marca true si la última lectura es más vieja que 2 × intervalo (o no hay lectura).
  final bool datosDesactualizados;

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
    this.datosDesactualizados = false,
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
        datosDesactualizados: json['datosDesactualizados'] as bool? ?? false,
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
    bool? datosDesactualizados,
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
        datosDesactualizados: datosDesactualizados ?? this.datosDesactualizados,
      );

  @override
  List<Object?> get props => [
        id, estado, temperatura, humedad, humedadGrano,
        ultimaActualizacion, loteActivoId, datosDesactualizados,
      ];
}
