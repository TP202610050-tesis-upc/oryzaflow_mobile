enum UserRole { operador, supervisor, admin }

extension UserRoleExtension on UserRole {
  String get displayName => switch (this) {
        UserRole.operador => 'Operador',
        UserRole.supervisor => 'Supervisor',
        UserRole.admin => 'Administrador',
      };

  bool get puedeEditarPerfiles =>
      this == UserRole.supervisor || this == UserRole.admin;
  bool get puedeCrearPerfiles => this == UserRole.admin;
  bool get puedeGestionarNodos => this == UserRole.admin;
  bool get puedeVerUsuarios => this == UserRole.admin;
  bool get puedeCalibrarSensores =>
      this == UserRole.supervisor || this == UserRole.admin;
}
