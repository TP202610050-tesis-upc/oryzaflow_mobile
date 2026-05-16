import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/enums/user_role.dart';

class RoleBadge extends StatelessWidget {
  final UserRole rol;
  final bool compact;

  const RoleBadge({super.key, required this.rol, this.compact = false});

  Color get _color => switch (rol) {
        UserRole.admin => AppColors.critico,
        UserRole.supervisor => AppColors.informacion,
        UserRole.operador => AppColors.verde,
      };

  Color get _bgColor => switch (rol) {
        UserRole.admin => AppColors.criticoFondo,
        UserRole.supervisor => AppColors.informacionFondo,
        UserRole.operador => AppColors.verdeFondo,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimensions.paddingXs : AppDimensions.paddingS,
        vertical: AppDimensions.paddingXs,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Text(
        rol.displayName,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
