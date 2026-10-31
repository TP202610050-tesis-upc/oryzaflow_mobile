import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/manual_reading_model.dart';
import '../../models/pair_model.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

/// HU-013 (CA-013-01/02): registrar la lectura del medidor PM-410 (tres lecturas de la misma muestra) y ver
/// estimación y lectura lado a lado con la diferencia en puntos porcentuales. La marca "por verificar" y la
/// alerta las decide el backend (umbral 1,0 pp, experta); aquí solo se muestran.
class ManualReadingsScreen extends StatelessWidget {
  final String loteId;
  const ManualReadingsScreen({super.key, required this.loteId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = sl<BatchProvider>();
        p.cargarLote(loteId);
        p.cargarPares(loteId);
        return p;
      },
      child: _ManualReadingsView(loteId: loteId),
    );
  }
}

class _ManualReadingsView extends StatefulWidget {
  final String loteId;
  const _ManualReadingsView({required this.loteId});

  @override
  State<_ManualReadingsView> createState() => _ManualReadingsViewState();
}

class _ManualReadingsViewState extends State<_ManualReadingsView> {
  final _formKey = GlobalKey<FormState>();
  final _l1 = TextEditingController();
  final _l2 = TextEditingController();
  final _l3 = TextEditingController();
  final _tGrano = TextEditingController();
  Mantada _mantada = Mantada.m1;

  @override
  void dispose() {
    _l1.dispose();
    _l2.dispose();
    _l3.dispose();
    _tGrano.dispose();
    super.dispose();
  }

  String? _validarLectura(String? v) {
    if (v == null || v.isEmpty) return AppStrings.campoRequerido;
    final d = double.tryParse(v.replaceAll(',', '.'));
    if (d == null) return 'Número inválido';
    if (d < 5 || d > 40) return 'Entre 5 y 40 % b.h.';
    return null;
  }

  double _num(TextEditingController c) => double.parse(c.text.replaceAll(',', '.'));

  Future<void> _registrar(BatchProvider prov) async {
    if (!_formKey.currentState!.validate()) return;
    final draft = ManualReadingDraft(
      mantada: _mantada,
      lectura1: _num(_l1),
      lectura2: _num(_l2),
      lectura3: _num(_l3),
      temperaturaGrano: _tGrano.text.trim().isEmpty ? null : _num(_tGrano),
    );
    if (draft.rango > 0.5) {
      // Regla del protocolo (anexo B): rango > 0,5 pp entre lecturas → repetir la medición.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Rango entre lecturas = ${draft.rango.toStringAsFixed(2)} pp > 0,5: repita la medición'),
        backgroundColor: AppColors.advertencia,
      ));
      return;
    }
    final creada = await prov.registrarLecturaManual(widget.loteId, draft);
    if (!mounted) return;
    if (creada != null) {
      _l1.clear();
      _l2.clear();
      _l3.clear();
      _tGrano.clear();
      final lote = prov.loteSeleccionado;
      final msg = (lote != null && lote.porVerificar && lote.ultimaDiferenciaPp != null)
          ? 'La app difiere del medidor en ${lote.ultimaDiferenciaPp!.abs().toStringAsFixed(1)} puntos — vuelva a medir'
          : '${AppStrings.lecturaRegistrada}: promedio ${creada.promedio.toStringAsFixed(2)} %';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: (lote?.porVerificar ?? false) ? AppColors.advertencia : AppColors.verde,
        duration: const Duration(seconds: 5),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.error ?? 'No se pudo registrar la lectura'),
        backgroundColor: AppColors.critico,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (_, prov, __) {
        final lote = prov.loteSeleccionado;
        return Scaffold(
          appBar: OryzaFlowAppBar(
            titulo: lote != null ? '${AppStrings.lecturasMedidor} · ${lote.codigo}' : AppStrings.lecturasMedidor,
            mostrarBotonAtras: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await prov.refrescarLote(widget.loteId);
              await prov.cargarPares(widget.loteId);
            },
            color: AppColors.verde,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                if (lote != null && lote.porVerificar) _PorVerificarBanner(diferencia: lote.ultimaDiferenciaPp),
                _FormCard(
                  formKey: _formKey,
                  l1: _l1,
                  l2: _l2,
                  l3: _l3,
                  tGrano: _tGrano,
                  mantada: _mantada,
                  onMantada: (m) => setState(() => _mantada = m),
                  validar: _validarLectura,
                  procesando: prov.estaProcesando,
                  onRegistrar: () => _registrar(prov),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text('Estimación vs. medidor',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.paddingS),
                if (prov.estaCargandoPares)
                  const ShimmerList()
                else if (prov.pares == null || prov.pares!.pares.isEmpty)
                  const EmptyStateWidget(
                      icono: Icons.straighten_rounded,
                      mensaje: AppStrings.sinLecturasManuales)
                else ...[
                  _ResumenPares(pares: prov.pares!),
                  const SizedBox(height: AppDimensions.paddingS),
                  ...prov.pares!.pares.reversed.map((p) => _PairTile(par: p)),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PorVerificarBanner extends StatelessWidget {
  final double? diferencia;
  const _PorVerificarBanner({this.diferencia});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.advertenciaFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.advertencia.withAlpha(120)),
      ),
      child: Row(
        children: [
          const Icon(Icons.rule_rounded, color: AppColors.advertencia),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              diferencia != null
                  ? 'La app difiere del medidor en ${diferencia!.abs().toStringAsFixed(1)} puntos — vuelva a medir'
                  : AppStrings.porVerificar,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.advertencia),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController l1, l2, l3, tGrano;
  final Mantada mantada;
  final ValueChanged<Mantada> onMantada;
  final String? Function(String?) validar;
  final bool procesando;
  final VoidCallback onRegistrar;

  const _FormCard({
    required this.formKey,
    required this.l1,
    required this.l2,
    required this.l3,
    required this.tGrano,
    required this.mantada,
    required this.onMantada,
    required this.validar,
    required this.procesando,
    required this.onRegistrar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lectura del medidor PM-410', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              const Text(
                'Tres lecturas de la misma muestra (% b.h.). Si difieren más de 0,5 pp, repita la medición.',
                style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  const Text(AppStrings.mantada, style: TextStyle(fontSize: 13, color: AppColors.textoSecundario)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<Mantada>(
                      segments: Mantada.values
                          .map((m) => ButtonSegment(value: m, label: Text(m.displayName)))
                          .toList(),
                      selected: {mantada},
                      onSelectionChanged: (s) => onMantada(s.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  Expanded(child: _NumField(controller: l1, label: 'Lectura 1', validator: validar)),
                  const SizedBox(width: 8),
                  Expanded(child: _NumField(controller: l2, label: 'Lectura 2', validator: validar)),
                  const SizedBox(width: 8),
                  Expanded(child: _NumField(controller: l3, label: 'Lectura 3', validator: validar)),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _NumField(controller: tGrano, label: 'T. grano (°C, opcional)', validator: (_) => null),
              const SizedBox(height: AppDimensions.paddingM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: procesando ? null : onRegistrar,
                  icon: procesando
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: const Text(AppStrings.registrarLectura),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  const _NumField({required this.controller, required this.label, required this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, isDense: true),
      validator: validator,
    );
  }
}

class _ResumenPares extends StatelessWidget {
  final PairsModel pares;
  const _ResumenPares({required this.pares});

  @override
  Widget build(BuildContext context) {
    final mae = pares.mae;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.verdeFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          _Kpi('Lecturas', '${pares.n}'),
          _Kpi('Emparejadas', '${pares.emparejados}'),
          _Kpi('MAE', mae != null ? '${mae.toStringAsFixed(2)} pp' : '—'),
          _Kpi('Ventana', '±${pares.ventanaMinutos} min'),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String k, v;
  const _Kpi(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.verde)),
          Text(k, style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario)),
        ],
      ),
    );
  }
}

/// Estimación y lectura lado a lado con la diferencia en pp (CA-013-01).
class _PairTile extends StatelessWidget {
  final PairModel par;
  const _PairTile({required this.par});

  @override
  Widget build(BuildContext context) {
    final err = par.error;
    final fuera = err != null && err.abs() > 1.0;
    final color = !par.emparejada
        ? AppColors.textoSecundario
        : (fuera ? AppColors.advertencia : AppColors.verde);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${DateFormatter.relativo(par.tsMedida)} · ${par.mantada}${par.segmento != null ? ' · seg. ${par.segmento}' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Val('Estimación', par.mEstimada != null ? '${par.mEstimada!.toStringAsFixed(2)} %' : '—'),
                      const SizedBox(width: 16),
                      _Val('Medidor', '${par.mMedida.toStringAsFixed(2)} %'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Text(
                !par.emparejada
                    ? 'sin telemetría'
                    : '${err! >= 0 ? '+' : ''}${err.toStringAsFixed(2)} pp',
                style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Val extends StatelessWidget {
  final String k, v;
  const _Val(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario)),
        Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
