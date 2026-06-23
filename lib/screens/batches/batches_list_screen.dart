import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/batch_status.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/batch_model.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class BatchesListScreen extends StatelessWidget {
  const BatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<BatchProvider>()..cargarLotes(),
      child: const _BatchesView(),
    );
  }
}

class _BatchesView extends StatefulWidget {
  const _BatchesView();

  @override
  State<_BatchesView> createState() => _BatchesViewState();
}

class _BatchesViewState extends State<_BatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.lotes,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'En proceso'),
            Tab(text: 'Historial'),
          ],
          indicatorColor: AppColors.verde,
          labelColor: AppColors.verde,
          unselectedLabelColor: AppColors.textoSecundario,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.nuevoLote),
        backgroundColor: AppColors.verde,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(AppStrings.nuevoLote,
            style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<BatchProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarLotes);
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _LotesList(
                lotes: prov.lotesActivos,
                emptyMsg: 'Sin lotes activos',
                onRefresh: prov.cargarLotes,
              ),
              _LotesList(
                lotes: prov.lotesHistorial,
                emptyMsg: 'Sin historial de lotes',
                onRefresh: prov.cargarLotes,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LotesList extends StatelessWidget {
  final List<BatchModel> lotes;
  final String emptyMsg;
  final Future<void> Function() onRefresh;

  const _LotesList({
    required this.lotes,
    required this.emptyMsg,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (lotes.isEmpty) {
      return EmptyStateWidget(
          icono: Icons.inventory_2_outlined, mensaje: emptyMsg);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.verde,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        itemCount: lotes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.paddingS),
        itemBuilder: (_, i) => _BatchCard(lote: lotes[i]),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel lote;
  const _BatchCard({required this.lote});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorBatchStatus(lote.estado);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        onTap: () => context.push(RouteNames.detalleLotePath(lote.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.informacionFondo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        size: 20, color: AppColors.informacion),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lote.codigo,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(
                            '${lote.variedadNombre} • ${lote.siloNombre}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textoSecundario)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withAlpha(60)),
                    ),
                    child: Text(lote.estado.displayName,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _InfoChip(
                      icon: Icons.scale_rounded,
                      label: '${(lote.pesoKg / 1000).toStringAsFixed(1)}t'),
                  const SizedBox(width: 8),
                  _InfoChip(
                      icon: Icons.water_drop_outlined,
                      label:
                          'H: ${lote.humedadInicial.toStringAsFixed(1)}%${lote.humedadFinal != null ? ' → ${lote.humedadFinal!.toStringAsFixed(1)}%' : ''}'),
                  const Spacer(),
                  Text(
                    DateFormatter.fecha(lote.fechaIngreso),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textoSecundario),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textoSecundario),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textoSecundario)),
      ],
    );
  }
}
