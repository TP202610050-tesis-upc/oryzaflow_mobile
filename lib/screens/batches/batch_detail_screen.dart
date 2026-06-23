import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/batch_status.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/batch_model.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/sensor_chart_card.dart';

class BatchDetailScreen extends StatelessWidget {
  final String loteId;
  const BatchDetailScreen({super.key, required this.loteId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = sl<BatchProvider>();
        p.cargarLote(loteId);
        p.cargarLecturas(loteId);
        return p;
      },
      child: _BatchDetailView(loteId: loteId),
    );
  }
}

class _BatchDetailView extends StatelessWidget {
  final String loteId;
  const _BatchDetailView({required this.loteId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error,
                onReintentar: () {
                  prov.cargarLote(loteId);
                  prov.cargarLecturas(loteId);
                }),
          );
        }
        final lote = prov.loteSeleccionado;
        if (lote == null) {
          return const Scaffold(
              appBar: OryzaFlowAppBar(
                  titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
              body: EmptyStateWidget(mensaje: 'Lote no encontrado'));
        }

        return Scaffold(
          appBar: OryzaFlowAppBar(
            titulo: lote.codigo,
            mostrarBotonAtras: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await prov.cargarLote(lote.id);
              await prov.cargarLecturas(lote.id);
            },
            color: AppColors.verde,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                _StatusBanner(lote: lote),
                const SizedBox(height: AppDimensions.paddingM),
                _InfoSection(lote: lote),
                const SizedBox(height: AppDimensions.paddingM),
                _ControlSection(lote: lote, prov: prov),
                const SizedBox(height: AppDimensions.paddingM),
                Text(AppStrings.ultimasDoceHoras,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.paddingS),
                ...SensorTipo.values.map((t) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingM),
                      child: SensorChartCard(
                        tipo: t,
                        lecturas: prov.lecturas,
                        estaCargando: prov.estaCargandoLecturas,
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final BatchModel lote;
  const _StatusBanner({required this.lote});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorBatchStatus(lote.estado);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lote.estado.displayName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: color)),
              ],
            ),
          ),
          if (lote.duracion != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Duración',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textoSecundario)),
                Text(
                    '${lote.duracion!.inHours}h ${lote.duracion!.inMinutes.remainder(60)}min',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: color)),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final BatchModel lote;
  const _InfoSection({required this.lote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del Lote',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            _Row('Variedad', lote.variedadNombre),
            _Row('Silo', lote.siloNombre),
            _Row('Nodo', lote.nodoNombre),
            _Row('Perfil de secado', lote.perfilSecadoNombre),
            _Row('Peso', '${(lote.pesoKg / 1000).toStringAsFixed(2)} t'),
            _Row('Humedad inicial',
                '${lote.humedadInicial.toStringAsFixed(1)} %'),
            if (lote.humedadFinal != null)
              _Row('Humedad final',
                  '${lote.humedadFinal!.toStringAsFixed(1)} %'),
            _Row('Ingreso', DateFormatter.fechaHora(lote.fechaIngreso)),
            if (lote.fechaInicio != null)
              _Row('Inicio secado',
                  DateFormatter.fechaHora(lote.fechaInicio!)),
            if (lote.fechaFin != null)
              _Row('Fin secado',
                  DateFormatter.fechaHora(lote.fechaFin!)),
            _Row('Operador', lote.operadorNombre),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String valor;
  const _Row(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textoSecundario)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  final BatchModel lote;
  final BatchProvider prov;
  const _ControlSection({required this.lote, required this.prov});

  @override
  Widget build(BuildContext context) {
    if (lote.estado == BatchStatus.completado ||
        lote.estado == BatchStatus.cancelado) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Control de Secado',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            if (lote.estado == BatchStatus.pendiente)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: prov.estaProcesando
                      ? null
                      : () async {
                          final ok = await prov.iniciarSecado(lote.id);
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(prov.error ?? 'Error'),
                                  backgroundColor: AppColors.critico),
                            );
                          }
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(AppStrings.iniciarSecado),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white),
                ),
              ),
            if (lote.estado == BatchStatus.enProceso)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: prov.estaProcesando
                      ? null
                      : () async {
                          final ok = await prov.detenerSecado(lote.id);
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(prov.error ?? 'Error'),
                                  backgroundColor: AppColors.critico),
                            );
                          }
                        },
                  icon: const Icon(Icons.stop_rounded,
                      color: AppColors.critico),
                  label: const Text(AppStrings.detenerSecado,
                      style: TextStyle(color: AppColors.critico)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.critico)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
