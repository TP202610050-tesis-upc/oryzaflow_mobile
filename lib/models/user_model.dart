import 'package:equatable/equatable.dart';
import '../core/enums/user_role.dart';

class UserModel extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String passwordHash;
  final UserRole rol;
  final bool activo;
  final String? telefono;
  final DateTime creadoEn;

  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.passwordHash,
    required this.rol,
    required this.activo,
    required this.creadoEn,
    this.telefono,
  });

  UserModel copyWith({
    String? nombre,
    String? email,
    String? passwordHash,
    UserRole? rol,
    bool? activo,
    String? telefono,
  }) =>
      UserModel(
        id: id,
        nombre: nombre ?? this.nombre,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        rol: rol ?? this.rol,
        activo: activo ?? this.activo,
        telefono: telefono ?? this.telefono,
        creadoEn: creadoEn,
      );

  @override
  List<Object?> get props => [id, email, rol, activo];
}
