import 'package:equatable/equatable.dart';
import '../core/enums/user_role.dart';
import '../core/network/json_mappers.dart';

class UserModel extends Equatable {
  final String id;
  final String nombre;
  final String email;
  // Solo lo usan los mocks; el backend nunca devuelve el hash.
  final String? passwordHash;
  final UserRole rol;
  final bool activo;
  final String? telefono;
  final DateTime creadoEn;

  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    required this.creadoEn,
    this.passwordHash,
    this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        nombre: json['nombre'] as String? ?? '',
        email: json['email'] as String? ?? '',
        rol: userRoleFromApi(json['roles'] as List<dynamic>?),
        activo: json['activo'] as bool? ?? true,
        telefono: json['telefono'] as String?,
        creadoEn: parseFecha(json['createdAt']),
      );

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
