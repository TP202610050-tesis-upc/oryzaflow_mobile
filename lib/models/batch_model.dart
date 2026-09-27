import 'package:equatable/equatable.dart';
import '../core/enums/batch_status.dart';
import '../core/enums/producto_destino.dart';
import '../core/network/json_mappers.dart';
import 'batch_estimation_model.dart';

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

  // Campos de campaña (F7) y reglas de excepción (Cuaderno 4, 27/09/2026).
  /// Destino comercial: obligatorio al registrar (CA-006-02).
  final ProductoDestino? producto;
  final double? metaDeclarada;
  /// Código del dueño del grano (anexo A del protocolo); "dueño" en la lista de lotes (HU-015).
  final String? duenoCodigo;
  /// CA-013-02: la estimación difiere del medidor > 1,0 pp; no se da el lote por listo solo con ella.
  final bool porVerificar;
  final double? ultimaDiferenciaPp;
  final int alertasNoLeidas;
  /// HU-001/HU-003: última estimación del nodo con su antigüedad y proyección (null si no está en proceso).
  final BatchEstimationModel? estimacion;

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
    this.producto,
    this.metaDeclarada,
    this.duenoCodigo,
    this.porVerificar = false,
    this.ultimaDiferenciaPp,
    this.alertasNoLeidas = 0,
    this.estimacion,
  });

  bool get estaActivo => estado == BatchStatus.enProceso;
  Duration? get duracion =>
      fechaFin != null && fechaInicio != null
          ? fechaFin!.difference(fechaInicio!)
          : null;

  /// Dueño del grano si se registró; si no, el operador que creó el lote.
  String get dueno =>
      (duenoCodigo != null && duenoCodigo!.isNotEmpty) ? duenoCodigo! : operadorNombre;

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
        producto: productoDestinoFromApi(json['producto'] as String?),
        metaDeclarada: parseDoubleNullable(json['metaDeclarada']),
        duenoCodigo: json['duenoCodigo'] as String?,
        porVerificar: json['porVerificar'] as bool? ?? false,
        ultimaDiferenciaPp: parseDoubleNullable(json['ultimaDiferenciaPp']),
        alertasNoLeidas: (json['alertasNoLeidas'] as num?)?.toInt() ?? 0,
        estimacion: json['estimacion'] is Map<String, dynamic>
            ? BatchEstimationModel.fromJson(json['estimacion'] as Map<String, dynamic>)
            : null,
      );

  /// Payload de creación (CreateBatchResource). El operador lo toma el backend del token.
  /// `producto` es obligatorio en el backend (CA-006-02).
  Map<String, dynamic> toCreateJson() => {
        'siloId': int.tryParse(siloId),
        'variedadId': int.tryParse(variedadId),
        'perfilSecadoId': int.tryParse(perfilSecadoId),
        'nodoId': int.tryParse(nodoId),
        'pesoKg': pesoKg,
        'humedadInicial': humedadInicial,
        if (producto != null) 'producto': productoDestinoToApi(producto!),
        if (metaDeclarada != null) 'metaDeclarada': metaDeclarada,
        if (duenoCodigo != null && duenoCodigo!.isNotEmpty) 'duenoCodigo': duenoCodigo,
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
        producto: producto,
        metaDeclarada: metaDeclarada,
        duenoCodigo: duenoCodigo,
        porVerificar: porVerificar,
        ultimaDiferenciaPp: ultimaDiferenciaPp,
        alertasNoLeidas: alertasNoLeidas,
        estimacion: estimacion,
      );

  @override
  List<Object?> get props => [id, estado, humedadFinal, porVerificar, estimacion];
}
