import '../enums/batch_status.dart';
import '../enums/node_status.dart';
import '../enums/user_role.dart';
import '../../models/silo_model.dart';

/// Helpers de (de)serialización compartidos por los `fromJson/toJson` reales.
/// El backend usa ISO-8601 para fechas y UPPER_SNAKE para los enums.

DateTime? parseFechaNullable(dynamic v) =>
    v == null ? null : DateTime.parse(v as String).toLocal();

DateTime parseFecha(dynamic v) =>
    v == null ? DateTime.now() : DateTime.parse(v as String).toLocal();

double parseDouble(dynamic v, [double fallback = 0]) =>
    v == null ? fallback : (v as num).toDouble();

double? parseDoubleNullable(dynamic v) =>
    v == null ? null : (v as num).toDouble();

// ── BatchStatus ↔ backend (PENDIENTE/EN_PROCESO/COMPLETADO/CANCELADO) ──
BatchStatus batchStatusFromApi(String s) => switch (s) {
      'PENDIENTE' => BatchStatus.pendiente,
      'EN_PROCESO' => BatchStatus.enProceso,
      'COMPLETADO' => BatchStatus.completado,
      'CANCELADO' => BatchStatus.cancelado,
      _ => BatchStatus.pendiente,
    };

String batchStatusToApi(BatchStatus s) => switch (s) {
      BatchStatus.pendiente => 'PENDIENTE',
      BatchStatus.enProceso => 'EN_PROCESO',
      BatchStatus.completado => 'COMPLETADO',
      BatchStatus.cancelado => 'CANCELADO',
    };

// ── UserRole ↔ backend (lista de roles tipo ROLE_ADMIN) ──
UserRole userRoleFromApi(List<dynamic>? roles) {
  final first = (roles == null || roles.isEmpty)
      ? ''
      : roles.first.toString().toUpperCase().replaceFirst('ROLE_', '');
  return switch (first) {
    'ADMIN' => UserRole.admin,
    'SUPERVISOR' => UserRole.supervisor,
    _ => UserRole.operador,
  };
}

String userRoleToApi(UserRole rol) => switch (rol) {
      UserRole.admin => 'ROLE_ADMIN',
      UserRole.supervisor => 'ROLE_SUPERVISOR',
      UserRole.operador => 'ROLE_OPERADOR',
    };

// ── SiloStatus ↔ backend (DISPONIBLE/OCUPADO/MANTENIMIENTO/DE_BAJA) ──
SiloStatus siloStatusFromApi(String s) => switch (s) {
      'DISPONIBLE' => SiloStatus.disponible,
      'OCUPADO' => SiloStatus.ocupado,
      'MANTENIMIENTO' => SiloStatus.mantenimiento,
      'DE_BAJA' => SiloStatus.deBaja,
      _ => SiloStatus.disponible,
    };

String siloStatusToApi(SiloStatus s) => switch (s) {
      SiloStatus.disponible => 'DISPONIBLE',
      SiloStatus.ocupado => 'OCUPADO',
      SiloStatus.mantenimiento => 'MANTENIMIENTO',
      SiloStatus.deBaja => 'DE_BAJA',
    };

// ── NodeStatus ↔ backend (ACTIVO/INACTIVO/ALERTA/DESCONECTADO) ──
NodeStatus nodeStatusFromApi(String s) => switch (s) {
      'ACTIVO' => NodeStatus.activo,
      'INACTIVO' => NodeStatus.inactivo,
      'ALERTA' => NodeStatus.alerta,
      'DESCONECTADO' => NodeStatus.desconectado,
      _ => NodeStatus.desconectado,
    };

String nodeStatusToApi(NodeStatus s) => switch (s) {
      NodeStatus.activo => 'ACTIVO',
      NodeStatus.inactivo => 'INACTIVO',
      NodeStatus.alerta => 'ALERTA',
      NodeStatus.desconectado => 'DESCONECTADO',
    };
