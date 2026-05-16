enum DryingStage {
  precalentamiento,
  secado,
  enfriamiento,
  completado,
  detenido,
}

extension DryingStagExtension on DryingStage {
  String get displayName => switch (this) {
        DryingStage.precalentamiento => 'Precalentamiento',
        DryingStage.secado => 'Secado',
        DryingStage.enfriamiento => 'Enfriamiento',
        DryingStage.completado => 'Completado',
        DryingStage.detenido => 'Detenido',
      };

  bool get estaActivo =>
      this == DryingStage.precalentamiento ||
      this == DryingStage.secado ||
      this == DryingStage.enfriamiento;
}
