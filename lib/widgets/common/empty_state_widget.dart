import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? mensaje;
  final IconData? icono;
  final Widget? accion;

  const EmptyStateWidget({super.key, this.mensaje, this.icono, this.accion});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono ?? Icons.inbox_rounded,
                size: 56, color: AppColors.textoDeshabilitado),
            const SizedBox(height: 16),
            Text(
              mensaje ?? AppStrings.sinDatos,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textoSecundario),
            ),
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
