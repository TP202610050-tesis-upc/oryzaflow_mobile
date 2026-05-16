enum BatchStatus { pendiente, enProceso, completado, cancelado }

extension BatchStatusExtension on BatchStatus {
  String get displayName => switch (this) {
        BatchStatus.pendiente => 'Pendiente',
        BatchStatus.enProceso => 'En Proceso',
        BatchStatus.completado => 'Completado',
        BatchStatus.cancelado => 'Cancelado',
      };

  bool get estaActivo => this == BatchStatus.enProceso;
}
