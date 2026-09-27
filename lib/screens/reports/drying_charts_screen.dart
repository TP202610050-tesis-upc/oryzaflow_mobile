import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/batch_model.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/sensor_chart_card.dart';

class DryingChartsScreen extends StatelessWidget {
  final String? loteId;
  const DryingChartsScreen({super.key, this.loteId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = sl<BatchProvider>();
        if (loteId != null) {
          p.cargarLote(loteId!);
          p.cargarLecturas(loteId!);
        }
        return p;
      },
      child: const _ChartsView(),
    );
  }
}

class _ChartsView extends StatelessWidget {
  const _ChartsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (_, prov, __) {
        final lote = prov.loteSeleccionado;
        final titulo = lote?.codigo ?? AppStrings.graficasSecado;

        if (prov.estaCargando) {
          return Scaffold(
            appBar: OryzaFlowAppBar(
                titulo: titulo, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null && lote == null) {
          return Scaffold(
            appBar: OryzaFlowAppBar(
                titulo: titulo, mostrarBotonAtras: true),
            body:
                ErrorStateWidget(mensaje: prov.error, onReintentar: () {}),
          );
        }
        if (lote == null) {
          return Scaffold(
            appBar: OryzaFlowAppBar(
                titulo: titulo, mostrarBotonAtras: true),
            body: const EmptyStateWidget(
                mensaje: 'Selecciona un lote para ver sus gráficas'),
          );
        }

        // CA-009-02: con menos de dos estimaciones no hay curva que mostrar (no un gráfico vacío).
        final estimaciones =
            prov.lecturas.where((r) => r.tieneEstimacion).length;
        final curvaInsuficiente =
            !prov.estaCargandoLecturas && estimaciones < 2;

        return Scaffold(
          appBar: OryzaFlowAppBar(
            titulo: lote.codigo,
            mostrarBotonAtras: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            children: [
              _LoteInfo(lote: lote),
              const SizedBox(height: AppDimensions.paddingM),
              Text(AppStrings.ultimasDoceHoras,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppDimensions.paddingS),
              if (curvaInsuficiente)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyStateWidget(
                        icono: Icons.show_chart_rounded,
                        mensaje: AppStrings.curvaSinDatos),
                  ),
                )
              else
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
        );
      },
    );
  }
}

class _LoteInfo extends StatelessWidget {
  final BatchModel lote;
  const _LoteInfo({required this.lote});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lote.variedadNombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.verde)),
                Text('${lote.siloNombre} • ${lote.nodoNombre}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textoSecundario)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(lote.pesoKg / 1000).toStringAsFixed(2)} t',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600)),
              Text(
                  'H: ${lote.humedadInicial.toStringAsFixed(1)}%${lote.humedadFinal != null ? ' → ${lote.humedadFinal!.toStringAsFixed(1)}%' : ''}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoSecundario)),
            ],
          ),
        ],
      ),
    );
  }
}
