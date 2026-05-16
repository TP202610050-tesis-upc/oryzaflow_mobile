import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? mensaje;
  final VoidCallback? onReintentar;

  const ErrorStateWidget({super.key, this.mensaje, this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.critico),
            const SizedBox(height: 16),
            Text(
              mensaje ?? AppStrings.errorCargando,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textoSecundario),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(AppStrings.reintentar),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
