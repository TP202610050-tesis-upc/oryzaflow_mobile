import 'package:equatable/equatable.dart';
import '../core/enums/batch_status.dart';
import '../core/network/json_mappers.dart';

class BatchModel extends Equatable {
  final String id;
  final String codigo;
  final String siloId;
  final String siloNombre;
  final String variedadId;
  final String variedadNombre;
  final String perfilSecadoId;
  final String perfilSecadoNombre;
  final String nodoId;
  final String nodoNombre;
  final BatchStatus estado;
  final double pesoKg;
  final double humedadInicial;
  final double? humedadFinal;
  final DateTime fechaIngreso;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String operadorId;
  final String operadorNombre;

  const BatchModel({
    required this.id,
    required this.codigo,
    required this.siloId,
    required this.siloNombre,
    required this.variedadId,
    required this.variedadNombre,
    required this.perfilSecadoId,
    required this.perfilSecadoNombre,
    required this.nodoId,
    required this.nodoNombre,
    required this.estado,
    required this.pesoKg,
    required this.humedadInicial,
    required this.fechaIngreso,
    required this.operadorId,
    required this.operadorNombre,
    this.humedadFinal,
    this.fechaInicio,
    this.fechaFin,
  });

  bool get estaActivo => estado == BatchStatus.enProceso;
  Duration? get duracion =>
      fechaFin != null && fechaInicio != null
          ? fechaFin!.difference(fechaInicio!)
          : null;

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
        id: json['id'].toString(),
        codigo: json['codigo'] as String? ?? '',
        siloId: json['siloId'].toString(),
        siloNombre: json['siloNombre'] as String? ?? '',
        variedadId: json['variedadId'].toString(),
        variedadNombre: json['variedadNombre'] as String? ?? '',
        perfilSecadoId: json['perfilSecadoId'].toString(),
        perfilSecadoNombre: json['perfilSecadoNombre'] as String? ?? '',
        nodoId: json['nodoId'].toString(),
        nodoNombre: json['nodoNombre'] as String? ?? '',
        estado: batchStatusFromApi(json['estado'] as String),
        pesoKg: parseDouble(json['pesoKg']),
        humedadInicial: parseDouble(json['humedadInicial']),
        humedadFinal: parseDoubleNullable(json['humedadFinal']),
        fechaIngreso: parseFecha(json['fechaIngreso']),
        fechaInicio: parseFechaNullable(json['fechaInicio']),
        fechaFin: parseFechaNullable(json['fechaFin']),
        operadorId: json['operadorId'].toString(),
        operadorNombre: json['operadorNombre'] as String? ?? '',
      );

  /// Payload de creación (CreateBatchResource). El operador lo toma el backend del token.
  Map<String, dynamic> toCreateJson() => {
        'siloId': int.tryParse(siloId),
        'variedadId': int.tryParse(variedadId),
        'perfilSecadoId': int.tryParse(perfilSecadoId),
        'nodoId': int.tryParse(nodoId),
        'pesoKg': pesoKg,
        'humedadInicial': humedadInicial,
      };

  BatchModel copyWith({
    BatchStatus? estado,
    double? humedadFinal,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) =>
      BatchModel(
        id: id,
        codigo: codigo,
        siloId: siloId,
        siloNombre: siloNombre,
        variedadId: variedadId,
        variedadNombre: variedadNombre,
        perfilSecadoId: perfilSecadoId,
        perfilSecadoNombre: perfilSecadoNombre,
        nodoId: nodoId,
        nodoNombre: nodoNombre,
        estado: estado ?? this.estado,
        pesoKg: pesoKg,
        humedadInicial: humedadInicial,
        humedadFinal: humedadFinal ?? this.humedadFinal,
        fechaIngreso: fechaIngreso,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin ?? this.fechaFin,
        operadorId: operadorId,
        operadorNombre: operadorNombre,
      );

  @override
  List<Object?> get props => [id, estado, humedadFinal];
}
