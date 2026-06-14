import 'package:equatable/equatable.dart';
import '../core/enums/node_status.dart';

class NodeModel extends Equatable {
  final String id;
  final String nombre;
  final String ubicacion;
  final NodeStatus estado;
  final double temperatura;
  final double humedad;
  final double flujoAire;
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
    required this.flujoAire,
    required this.humedadGrano,
    required this.ultimaActualizacion,
    required this.ipAddress,
    required this.intervaloEnvioSegundos,
    this.loteActivoId,
  });

  NodeModel copyWith({
    String? nombre,
    String? ubicacion,
    NodeStatus? estado,
    double? temperatura,
    double? humedad,
    double? flujoAire,
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
        flujoAire: flujoAire ?? this.flujoAire,
        humedadGrano: humedadGrano ?? this.humedadGrano,
        ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
        loteActivoId: loteActivoId ?? this.loteActivoId,
        ipAddress: ipAddress ?? this.ipAddress,
        intervaloEnvioSegundos:
            intervaloEnvioSegundos ?? this.intervaloEnvioSegundos,
      );

  @override
  List<Object?> get props =>
      [id, estado, temperatura, humedad, flujoAire, humedadGrano,
        ultimaActualizacion, loteActivoId];
}
