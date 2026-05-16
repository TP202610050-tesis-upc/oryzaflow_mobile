import 'package:equatable/equatable.dart';
import '../core/enums/batch_status.dart';
import '../core/enums/drying_stage.dart';

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
  final DryingStage? etapaActual;
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
    this.etapaActual,
    this.humedadFinal,
    this.fechaInicio,
    this.fechaFin,
  });

  bool get estaActivo => estado == BatchStatus.enProceso;
  Duration? get duracion =>
      fechaFin != null && fechaInicio != null
          ? fechaFin!.difference(fechaInicio!)
          : null;

  BatchModel copyWith({
    BatchStatus? estado,
    DryingStage? etapaActual,
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
        etapaActual: etapaActual ?? this.etapaActual,
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
  List<Object?> get props => [id, estado, etapaActual, humedadFinal];
}
