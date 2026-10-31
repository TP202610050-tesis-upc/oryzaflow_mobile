import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';

/// Aviso de que la pantalla muestra datos de la caché local (HU-010, CA-010-02).
class OfflineBanner extends StatelessWidget {
  final DateTime guardadoEn;
  const OfflineBanner({super.key, required this.guardadoEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingS + 2),
      decoration: BoxDecoration(
        color: AppColors.advertenciaFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.advertencia.withAlpha(120)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.advertencia),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.sinConexion} · ${AppStrings.datosGuardadosALas} '
                  '${DateFormatter.hora(guardadoEn.toLocal())}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.advertencia),
                ),
                const SizedBox(height: 2),
                const Text(AppStrings.offlineAcciones,
                    style: TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
