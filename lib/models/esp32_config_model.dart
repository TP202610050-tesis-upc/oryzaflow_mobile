import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Config de un nodo (Wi-Fi + offsets de calibración). El backend no tiene un recurso propio:
/// se arma desde NodeResource (GET /nodes/{id}) y se guarda vía PUT /config + PUT /calibration.
class Esp32ConfigModel extends Equatable {
  final String nodoId;
  final String ipAddress;
  final int puerto;
  final int intervaloEnvioSegundos;
  final double offsetTemperatura;
  final double offsetHumedad;
  final double offsetHumedadGrano;
  final bool wifiActivo;
  final String ssid;

  const Esp32ConfigModel({
    required this.nodoId,
    required this.ipAddress,
    required this.puerto,
    required this.intervaloEnvioSegundos,
    required this.offsetTemperatura,
    required this.offsetHumedad,
    required this.offsetHumedadGrano,
    required this.wifiActivo,
    required this.ssid,
  });

  /// Construye la config desde un NodeResource (que trae todos los campos).
  factory Esp32ConfigModel.fromNodeJson(Map<String, dynamic> json) =>
      Esp32ConfigModel(
        nodoId: json['id'].toString(),
        ipAddress: json['ipAddress'] as String? ?? '',
        puerto: (json['puerto'] as num?)?.toInt() ?? 0,
        intervaloEnvioSegundos:
            (json['intervaloEnvioSegundos'] as num?)?.toInt() ?? 0,
        offsetTemperatura: parseDouble(json['offsetTemperatura']),
        offsetHumedad: parseDouble(json['offsetHumedad']),
        offsetHumedadGrano: parseDouble(json['offsetHumedadGrano']),
        wifiActivo: json['wifiActivo'] as bool? ?? false,
        ssid: json['ssid'] as String? ?? '',
      );

  /// Payload de PUT /nodes/{id}/config (red/Wi-Fi).
  Map<String, dynamic> toConfigJson() => {
        'ssid': ssid,
        'wifiActivo': wifiActivo,
        'ipAddress': ipAddress,
        'puerto': puerto,
        'intervaloEnvioSegundos': intervaloEnvioSegundos,
      };

  /// Payload de PUT /nodes/{id}/calibration (offsets).
  Map<String, dynamic> toCalibrationJson() => {
        'offsetTemperatura': offsetTemperatura,
        'offsetHumedad': offsetHumedad,
        'offsetHumedadGrano': offsetHumedadGrano,
      };

  Esp32ConfigModel copyWith({
    String? ipAddress,
    int? puerto,
    int? intervaloEnvioSegundos,
    double? offsetTemperatura,
    double? offsetHumedad,
    double? offsetHumedadGrano,
    bool? wifiActivo,
    String? ssid,
  }) =>
      Esp32ConfigModel(
        nodoId: nodoId,
        ipAddress: ipAddress ?? this.ipAddress,
        puerto: puerto ?? this.puerto,
        intervaloEnvioSegundos:
            intervaloEnvioSegundos ?? this.intervaloEnvioSegundos,
        offsetTemperatura: offsetTemperatura ?? this.offsetTemperatura,
        offsetHumedad: offsetHumedad ?? this.offsetHumedad,
        offsetHumedadGrano: offsetHumedadGrano ?? this.offsetHumedadGrano,
        wifiActivo: wifiActivo ?? this.wifiActivo,
        ssid: ssid ?? this.ssid,
      );

  @override
  List<Object?> get props => [nodoId, ipAddress, intervaloEnvioSegundos];
}
