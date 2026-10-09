import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/segment_model.dart';

/// Diálogos de los eventos del lote (HU-010): cubrir, descubrir y detener. Confirmaciones de un
/// toque (restricción E-44): el único dato que piden es la lectura del PM-410 cuando aplica.

/// Cubrir: elige el motivo del cierre del tramo (NOCHE / LLUVIA). Devuelve null si se cancela.
Future<MotivoCierre?> mostrarDialogoCubrir(BuildContext context,
    {required String codigoLote}) {
  var motivo = MotivoCierre.noche;
  return showDialog<MotivoCierre>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('${AppStrings.cubrirLote} lote $codigoLote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.cubrirExplicacion),
            const SizedBox(height: 8),
            RadioGroup<MotivoCierre>(
              groupValue: motivo,
              onChanged: (v) => setState(() => motivo = v ?? motivo),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in MotivoCierre.values)
                    RadioListTile<MotivoCierre>(
                      value: m,
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.displayName),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text(AppStrings.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(motivo),
            style: TextButton.styleFrom(foregroundColor: AppColors.verde),
            child: const Text(AppStrings.cubrirLote,
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );
}

/// Descubrir: pide la M0 del tramo (PM-410, 5–40 % b.h.). Devuelve null si se cancela.
Future<double?> mostrarDialogoDescubrir(BuildContext context,
    {required String codigoLote}) {
  return showDialog<double>(
    context: context,
    builder: (ctx) => _DialogoNumero(
      titulo: '${AppStrings.descubrirLote} lote $codigoLote',
      explicacion: AppStrings.descubrirExplicacion,
      etiqueta: AppStrings.m0Tramo,
      obligatorio: true,
      textoConfirmar: AppStrings.descubrirLote,
      colorConfirmar: AppColors.verde,
    ),
  );
}

/// Resultado del diálogo de detener: confirmado con humedad final opcional.
class DetenerResultado {
  final double? humedadFinal;
  const DetenerResultado({this.humedadFinal});
}

/// Detener (recoger): confirma y permite registrar la humedad final del PM-410 (opcional, 5–40).
/// Devuelve null si se cancela.
Future<DetenerResultado?> mostrarDialogoDetener(BuildContext context,
    {required String codigoLote}) async {
  final v = await showDialog<_ResultadoNumero>(
    context: context,
    builder: (ctx) => _DialogoNumero(
      titulo: AppStrings.detenerSecado,
      explicacion: 'El lote «$codigoLote» pasará a Completado. '
          'Opcionalmente registre la humedad final medida con el PM-410.',
      etiqueta: AppStrings.humedadFinalOpcional,
      obligatorio: false,
      textoConfirmar: AppStrings.detener,
      colorConfirmar: AppColors.critico,
      envolver: true,
    ),
  );
  if (v == null) return null;
  return DetenerResultado(humedadFinal: v.valor);
}

class _ResultadoNumero {
  final double? valor;
  const _ResultadoNumero(this.valor);
}

/// Diálogo con un único campo numérico (% b.h.). Mismo criterio que `_validarLectura` de las
/// lecturas manuales: acepta coma decimal y exige 5–40.
class _DialogoNumero extends StatefulWidget {
  final String titulo;
  final String explicacion;
  final String etiqueta;
  final bool obligatorio;
  final String textoConfirmar;
  final Color colorConfirmar;
  /// true → devuelve `_ResultadoNumero` (permite distinguir "confirmado sin valor" de cancelar).
  final bool envolver;

  const _DialogoNumero({
    required this.titulo,
    required this.explicacion,
    required this.etiqueta,
    required this.obligatorio,
    required this.textoConfirmar,
    required this.colorConfirmar,
    this.envolver = false,
  });

  @override
  State<_DialogoNumero> createState() => _DialogoNumeroState();
}

class _DialogoNumeroState extends State<_DialogoNumero> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    if (v == null || v.trim().isEmpty) {
      return widget.obligatorio ? AppStrings.campoRequerido : null;
    }
    final d = double.tryParse(v.replaceAll(',', '.'));
    if (d == null) return 'Número inválido';
    if (d < 5 || d > 40) return AppStrings.rango5a40;
    return null;
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    final t = _ctrl.text.trim();
    final valor = t.isEmpty ? null : double.parse(t.replaceAll(',', '.'));
    Navigator.of(context).pop(widget.envolver ? _ResultadoNumero(valor) : valor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.explicacion),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: InputDecoration(
                labelText: widget.etiqueta,
                helperText: AppStrings.rango5a40,
                border: const OutlineInputBorder(),
              ),
              validator: _validar,
              onFieldSubmitted: (_) => _confirmar(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(AppStrings.cancelar),
        ),
        TextButton(
          onPressed: _confirmar,
          style: TextButton.styleFrom(foregroundColor: widget.colorConfirmar),
          child: Text(widget.textoConfirmar,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
