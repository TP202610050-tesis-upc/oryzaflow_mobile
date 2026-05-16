enum AlertSeverity { informacion, advertencia, critica }

extension AlertSeverityExtension on AlertSeverity {
  String get displayName => switch (this) {
        AlertSeverity.informacion => 'Información',
        AlertSeverity.advertencia => 'Advertencia',
        AlertSeverity.critica => 'Crítica',
      };
}
