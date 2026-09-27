import 'package:equatable/equatable.dart';
import '../core/network/json_mappers.dart';

/// Par estimación–medición (F7, CA-013-01): lectura del medidor y la telemetría del nodo más cercana (±5 min).
/// `error` = estimada − medida (pp, % b.h.); `emparejada=false` si no hubo telemetría en la ventana.
class PairModel extends Equatable {
  final String manualReadingId;
  final String mantada;
  final int? segmento;
  final DateTime tsMedida;
  final double mMedida;
  final DateTime? tsEstimada;
  final double? mEstimada;
  final double? error;
  final int? deltaSegundos;
  final bool emparejada;

  const PairModel({
    required this.manualReadingId,
    required this.mantada,
    required this.tsMedida,
    required this.mMedida,
    required this.emparejada,
    this.segmento,
    this.tsEstimada,
    this.mEstimada,
    this.error,
    this.deltaSegundos,
  });

  factory PairModel.fromJson(Map<String, dynamic> json) => PairModel(
        manualReadingId: json['manualReadingId'].toString(),
        mantada: json['mantada'] as String? ?? '',
        segmento: (json['segmento'] as num?)?.toInt(),
        tsMedida: parseFecha(json['tsMedida']),
        mMedida: parseDouble(json['mMedida']),
        tsEstimada: parseFechaNullable(json['tsEstimada']),
        mEstimada: parseDoubleNullable(json['mEstimada']),
        error: parseDoubleNullable(json['error']),
        deltaSegundos: (json['deltaSegundos'] as num?)?.toInt(),
        emparejada: json['emparejada'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [manualReadingId];
}

/// Respuesta de GET /batches/{id}/pairs: pares + resumen (MAE y sesgo sobre los emparejados).
class PairsModel extends Equatable {
  final String batchId;
  final String codigo;
  final int ventanaMinutos;
  final int n;
  final int emparejados;
  final double? mae;
  final double? sesgo;
  final List<PairModel> pares;

  const PairsModel({
    required this.batchId,
    required this.codigo,
    required this.ventanaMinutos,
    required this.n,
    required this.emparejados,
    required this.pares,
    this.mae,
    this.sesgo,
  });

  factory PairsModel.fromJson(Map<String, dynamic> json) => PairsModel(
        batchId: json['batchId'].toString(),
        codigo: json['codigo'] as String? ?? '',
        ventanaMinutos: (json['ventanaMinutos'] as num?)?.toInt() ?? 5,
        n: (json['n'] as num?)?.toInt() ?? 0,
        emparejados: (json['emparejados'] as num?)?.toInt() ?? 0,
        mae: parseDoubleNullable(json['mae']),
        sesgo: parseDoubleNullable(json['sesgo']),
        pares: (json['pares'] as List<dynamic>? ?? [])
            .map((e) => PairModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [batchId, n, emparejados];
}
