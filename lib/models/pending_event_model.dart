import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../core/utils/uuid_v4.dart';
import 'batch_model.dart';

/// Evento del lote que el jefe de cuadrilla registra desde la explanada (HU-010, CA-010-02).
/// Se guarda localmente con su hora y se envía al backend cuando hay señal.
enum TipoEvento { volteo, cubrir, descubrir, recoger }

enum EstadoEvento { pendiente, enviando, sincronizado, error }

extension TipoEventoX on TipoEvento {
  String get api => switch (this) {
        TipoEvento.volteo => 'VOLTEO',
        TipoEvento.cubrir => 'CUBRIR',
        TipoEvento.descubrir => 'DESCUBRIR',
        TipoEvento.recoger => 'RECOGER',
      };

  String get displayName => switch (this) {
        TipoEvento.volteo => 'Volteo',
        TipoEvento.cubrir => 'Cubrir',
        TipoEvento.descubrir => 'Descubrir',
        TipoEvento.recoger => 'Recoger (detener secado)',
      };

  IconData get icono => switch (this) {
        TipoEvento.volteo => Icons.autorenew_rounded,
        TipoEvento.cubrir => Icons.nights_stay_rounded,
        TipoEvento.descubrir => Icons.wb_sunny_rounded,
        TipoEvento.recoger => Icons.stop_circle_rounded,
      };

  /// SnackBar cuando el evento quedó guardado sin señal (CA-010-02: sin error ni reingreso).
  String mensajeGuardadoOffline(String hora) {
    final que = switch (this) {
      TipoEvento.volteo => 'volteo guardado',
      TipoEvento.cubrir => 'cubierta del lote guardada',
      TipoEvento.descubrir => 'descubierta del lote guardada',
      TipoEvento.recoger => 'recogida guardada',
    };
    return 'Sin señal: $que a las $hora. Se enviará al recuperar la conexión.';
  }

  /// SnackBar cuando el evento se envió al momento.
  String mensajeEnviado(String hora) => switch (this) {
        TipoEvento.volteo => 'Volteo registrado a las $hora',
        TipoEvento.cubrir => 'Lote cubierto a las $hora',
        TipoEvento.descubrir => 'Lote descubierto a las $hora',
        TipoEvento.recoger => 'Secado detenido a las $hora',
      };

  static TipoEvento fromApi(String? s) => switch (s) {
        'CUBRIR' => TipoEvento.cubrir,
        'DESCUBRIR' => TipoEvento.descubrir,
        'RECOGER' => TipoEvento.recoger,
        _ => TipoEvento.volteo,
      };
}

extension EstadoEventoX on EstadoEvento {
  String get api => switch (this) {
        EstadoEvento.pendiente => 'PENDIENTE',
        EstadoEvento.enviando => 'ENVIANDO',
        EstadoEvento.sincronizado => 'SINCRONIZADO',
        EstadoEvento.error => 'ERROR',
      };

  String get displayName => switch (this) {
        EstadoEvento.pendiente => 'Pendiente',
        EstadoEvento.enviando => 'Enviando…',
        EstadoEvento.sincronizado => 'Sincronizado',
        EstadoEvento.error => 'Error',
      };

  static EstadoEvento fromApi(String? s) => switch (s) {
        'ENVIANDO' => EstadoEvento.enviando,
        'SINCRONIZADO' => EstadoEvento.sincronizado,
        'ERROR' => EstadoEvento.error,
        _ => EstadoEvento.pendiente,
      };
}

class PendingEvent extends Equatable {
  /// UUID v4; viaja al backend como `clientEventId` (idempotencia).
  final String id;
  final TipoEvento tipo;
  final String loteId;
  final String loteCodigo;
  /// Hora del hecho (UTC). En pantalla se muestra `ts.toLocal()`.
  final DateTime ts;
  /// VOLTEO {metodo} | CUBRIR {motivo, humedadFinal?} | DESCUBRIR {m0} | RECOGER {humedadFinal?}
  final Map<String, dynamic> payload;
  final EstadoEvento estado;
  final int intentos;
  final String? ultimoError;
  final DateTime creadoEn;
  final DateTime? sincronizadoEn;
  final String? usuarioEmail;

  const PendingEvent({
    required this.id,
    required this.tipo,
    required this.loteId,
    required this.loteCodigo,
    required this.ts,
    required this.creadoEn,
    this.payload = const {},
    this.estado = EstadoEvento.pendiente,
    this.intentos = 0,
    this.ultimoError,
    this.sincronizadoEn,
    this.usuarioEmail,
  });

  factory PendingEvent.nuevo({
    required TipoEvento tipo,
    required BatchModel lote,
    required DateTime ts,
    Map<String, dynamic> payload = const {},
    String? usuarioEmail,
    DateTime? creadoEn,
  }) =>
      PendingEvent(
        id: uuidV4(),
        tipo: tipo,
        loteId: lote.id,
        loteCodigo: lote.codigo,
        ts: ts.toUtc(),
        payload: Map<String, dynamic>.from(payload),
        creadoEn: (creadoEn ?? DateTime.now()).toUtc(),
        usuarioEmail: usuarioEmail,
      );

  bool get terminado => estado == EstadoEvento.sincronizado;

  PendingEvent copyWith({
    EstadoEvento? estado,
    int? intentos,
    String? ultimoError,
    bool limpiarError = false,
    DateTime? sincronizadoEn,
  }) =>
      PendingEvent(
        id: id,
        tipo: tipo,
        loteId: loteId,
        loteCodigo: loteCodigo,
        ts: ts,
        payload: payload,
        creadoEn: creadoEn,
        estado: estado ?? this.estado,
        intentos: intentos ?? this.intentos,
        ultimoError: limpiarError ? null : (ultimoError ?? this.ultimoError),
        sincronizadoEn: sincronizadoEn ?? this.sincronizadoEn,
        usuarioEmail: usuarioEmail,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.api,
        'loteId': loteId,
        'loteCodigo': loteCodigo,
        'ts': ts.toUtc().toIso8601String(),
        'payload': payload,
        'estado': estado.api,
        'intentos': intentos,
        'ultimoError': ultimoError,
        'creadoEn': creadoEn.toUtc().toIso8601String(),
        'sincronizadoEn': sincronizadoEn?.toUtc().toIso8601String(),
        'usuarioEmail': usuarioEmail,
      };

  factory PendingEvent.fromJson(Map<String, dynamic> json) => PendingEvent(
        id: json['id'] as String,
        tipo: TipoEventoX.fromApi(json['tipo'] as String?),
        loteId: json['loteId'].toString(),
        loteCodigo: json['loteCodigo'] as String? ?? '',
        ts: DateTime.parse(json['ts'] as String).toUtc(),
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
        estado: EstadoEventoX.fromApi(json['estado'] as String?),
        intentos: (json['intentos'] as num?)?.toInt() ?? 0,
        ultimoError: json['ultimoError'] as String?,
        creadoEn: DateTime.tryParse(json['creadoEn'] as String? ?? '')?.toUtc() ??
            DateTime.parse(json['ts'] as String).toUtc(),
        sincronizadoEn: json['sincronizadoEn'] is String
            ? DateTime.tryParse(json['sincronizadoEn'] as String)?.toUtc()
            : null,
        usuarioEmail: json['usuarioEmail'] as String?,
      );

  @override
  List<Object?> get props =>
      [id, tipo, loteId, ts, estado, intentos, ultimoError, sincronizadoEn];
}
