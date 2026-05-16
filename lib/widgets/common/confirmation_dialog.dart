import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

Future<bool?> mostrarDialogoConfirmacion({
  required BuildContext context,
  required String titulo,
  required String mensaje,
  String textoCancelar = AppStrings.cancelar,
  String textoConfirmar = AppStrings.aceptar,
  bool esDestructivo = false,
}) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textoCancelar),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: esDestructivo ? AppColors.critico : AppColors.verde,
            ),
            child: Text(textoConfirmar,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
