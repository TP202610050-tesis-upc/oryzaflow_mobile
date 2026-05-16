import 'package:equatable/equatable.dart';

class Esp32ConfigModel extends Equatable {
  final String nodoId;
  final String ipAddress;
  final int puerto;
  final int intervaloEnvioSegundos;
  final double offsetTemperatura;
  final double offsetHumedad;
  final double offsetFlujoAire;
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
    required this.offsetFlujoAire,
    required this.offsetHumedadGrano,
    required this.wifiActivo,
    required this.ssid,
  });

  Esp32ConfigModel copyWith({
    String? ipAddress,
    int? puerto,
    int? intervaloEnvioSegundos,
    double? offsetTemperatura,
    double? offsetHumedad,
    double? offsetFlujoAire,
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
        offsetFlujoAire: offsetFlujoAire ?? this.offsetFlujoAire,
        offsetHumedadGrano: offsetHumedadGrano ?? this.offsetHumedadGrano,
        wifiActivo: wifiActivo ?? this.wifiActivo,
        ssid: ssid ?? this.ssid,
      );

  @override
  List<Object?> get props => [nodoId, ipAddress, intervaloEnvioSegundos];
}
