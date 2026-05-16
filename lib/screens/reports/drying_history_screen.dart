import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/route_names.dart';
import '../../core/enums/batch_status.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/batch_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class DryingHistoryScreen extends StatelessWidget {
  const DryingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ReportProvider>()..cargarHistorial(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.historialSecados,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        acciones: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: AppStrings.kpisGerenciales,
            onPressed: () => context.push(RouteNames.kpis),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: AppStrings.exportarReporte,
            onPressed: () => context.push(RouteNames.exportarReporte),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarHistorial);
          }

          return Column(
            children: [
              _FiltroFechas(prov: prov),
              Expanded(
                child: prov.historial.isEmpty
                    ? const EmptyStateWidget(
                        icono: Icons.history_toggle_off_rounded,
                        mensaje: 'Sin secados en el período')
                    : RefreshIndicator(
                        onRefresh: prov.cargarHistorial,
                        color: AppColors.verde,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          itemCount: prov.historial.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.paddingS),
                          itemBuilder: (_, i) =>
                              _HistoryCard(lote: prov.historial[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FiltroFechas extends StatelessWidget {
  final ReportProvider prov;
  const _FiltroFechas({required this.prov});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.date_range_rounded,
              size: 16, color: cs.onSurface.withAlpha(130)),
          const SizedBox(width: 8),
          _FechaChip(
            label: DateFormatter.fecha(prov.desde),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: prov.desde,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                prov.setFiltroFechas(picked, prov.hasta);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('—',
                style: TextStyle(color: cs.onSurface.withAlpha(130))),
          ),
          _FechaChip(
            label: DateFormatter.fecha(prov.hasta),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: prov.hasta,
                firstDate: prov.desde,
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                prov.setFiltroFechas(prov.desde, picked);
              }
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: prov.cargarHistorial,
            child: const Text('Aplicar',
                style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _FechaChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FechaChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurface)),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BatchModel lote;
  const _HistoryCard({required this.lote});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorBatchStatus(lote.estado);
    final duracion = lote.duracion;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        onTap: () => context.push(
            '${RouteNames.graficasSecado}?lote=${lote.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.inventory_2_rounded,
                    size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lote.codigo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('${lote.variedadNombre} • ${lote.siloNombre}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textoSecundario)),
                    if (lote.fechaInicio != null)
                      Text(DateFormatter.fecha(lote.fechaInicio!),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textoSecundario)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(lote.estado.displayName,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                  if (duracion != null) ...[
                    const SizedBox(height: 4),
                    Text(
                        '${duracion.inHours}h ${duracion.inMinutes.remainder(60)}min',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textoSecundario)),
                  ],
                  if (lote.humedadFinal != null)
                    Text(
                        'H.f: ${lote.humedadFinal!.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textoSecundario)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
