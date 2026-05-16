import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/kpi_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class KpiScreen extends StatelessWidget {
  const KpiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ReportProvider>()..cargarKpis(),
      child: const _KpiView(),
    );
  }
}

class _KpiView extends StatelessWidget {
  const _KpiView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OryzaFlowAppBar(
        titulo: AppStrings.kpisGerenciales,
        mostrarBotonAtras: true,
      ),
      body: Consumer<ReportProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarKpis);
          }
          if (prov.kpis == null) {
            return const EmptyStateWidget(
                icono: Icons.bar_chart_rounded, mensaje: 'Sin datos de KPIs');
          }

          return RefreshIndicator(
            onRefresh: prov.cargarKpis,
            color: AppColors.verde,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                _PeriodoBadge(kpis: prov.kpis!),
                const SizedBox(height: AppDimensions.paddingM),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.paddingS,
                  crossAxisSpacing: AppDimensions.paddingS,
                  childAspectRatio: 1.4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _KpiCard(
                      titulo: AppStrings.tasaExito,
                      valor:
                          '${prov.kpis!.tasaExitoPercent.toStringAsFixed(1)}%',
                      icono: Icons.check_circle_outline_rounded,
                      color: AppColors.verde,
                    ),
                    _KpiCard(
                      titulo: AppStrings.eficienciaEnergetica,
                      valor:
                          '${prov.kpis!.eficienciaEnergetica.toStringAsFixed(1)}%',
                      icono: Icons.bolt_rounded,
                      color: AppColors.advertencia,
                    ),
                    _KpiCard(
                      titulo: AppStrings.totalKgProcesados,
                      valor:
                          '${(prov.kpis!.totalKgProcesados / 1000).toStringAsFixed(1)} t',
                      icono: Icons.scale_rounded,
                      color: AppColors.informacion,
                    ),
                    _KpiCard(
                      titulo: AppStrings.tiempoPromedio,
                      valor:
                          '${prov.kpis!.tiempoPromedioHoras.toStringAsFixed(1)} h',
                      icono: Icons.timer_outlined,
                      color: AppColors.chartHumedadGrano,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _StatsSection(kpis: prov.kpis!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeriodoBadge extends StatelessWidget {
  final KpiModel kpis;
  const _PeriodoBadge({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.verdeFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: AppColors.verde),
          const SizedBox(width: 8),
          Text(
            'Período: ${_fmt(kpis.periodoDesde)} — ${_fmt(kpis.periodoHasta)}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.verde),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _KpiCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icono, size: 22, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                            color: color, fontWeight: FontWeight.w700)),
                Text(titulo,
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final KpiModel kpis;
  const _StatsSection({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas Detalladas',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            _StatRow('Lotes completados',
                '${kpis.totalLotesCompletados}'),
            _StatRow('Lotes cancelados',
                '${kpis.totalLotesCancelados}'),
            _StatRow('Humedad final promedio',
                '${kpis.humedadPromedioFinal.toStringAsFixed(1)} %'),
            _StatRow('Reducción de humedad promedio',
                '${kpis.reduccionHumedadPromedio.toStringAsFixed(1)} %'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String valor;
  const _StatRow(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textoSecundario)),
          Text(valor,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
