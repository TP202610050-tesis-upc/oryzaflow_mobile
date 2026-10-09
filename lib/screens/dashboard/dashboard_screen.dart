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
import '../../models/alert_model.dart';
import '../../models/batch_model.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/silo_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/sync_status_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<DashboardProvider>()..cargarDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuario;
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.dashboard,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        acciones: [
          const SyncStatusButton(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(RouteNames.alertas),
          ),
          if (user != null)
            GestureDetector(
              onTap: () => context.push(RouteNames.editarPerfil),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.verdeFondo,
                  child: Text(
                    user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.verde),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (_, provider, __) {
          if (provider.estaCargando) return _ShimmerDashboard();
          if (provider.error != null) {
            return ErrorStateWidget(
                mensaje: provider.error,
                onReintentar: provider.cargarDashboard);
          }
          if (provider.resumen == null) return const EmptyStateWidget();

          return RefreshIndicator(
            onRefresh: provider.cargarDashboard,
            color: AppColors.verde,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                if (user != null) _GreetingBanner(user.nombre),
                const SizedBox(height: AppDimensions.paddingM),
                _SummaryGrid(resumen: provider.resumen!),
                const SizedBox(height: AppDimensions.paddingM),
                _SectionHeader(titulo: 'Lotes en proceso', count: provider.lotesActivos.length, route: RouteNames.lotes),
                if (provider.lotesActivos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: EmptyStateWidget(mensaje: 'Sin lotes activos'),
                  )
                else
                  ...provider.lotesActivos.map((l) => _LoteTile(lote: l)),
                const SizedBox(height: AppDimensions.paddingM),
                _SectionHeader(titulo: 'Estado de silos', count: provider.silos.length, route: RouteNames.silos),
                _SilosRow(silos: provider.silos),
                const SizedBox(height: AppDimensions.paddingM),
                _SectionHeader(
                    titulo: AppStrings.alertasRecientes,
                    count: provider.alertasRecientes.length,
                    route: RouteNames.alertas),
                if (provider.alertasRecientes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: EmptyStateWidget(
                        mensaje: AppStrings.sinAlertas,
                        icono: Icons.check_circle_outline_rounded),
                  )
                else
                  ...provider.alertasRecientes.map((a) => _AlertaTile(alerta: a)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  final String nombre;
  const _GreetingBanner(this.nombre);

  @override
  Widget build(BuildContext context) {
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días' : hora < 18 ? 'Buenas tardes' : 'Buenas noches';
    return Text('$saludo, $nombre',
        style: Theme.of(context).textTheme.titleLarge);
  }
}

class _SectionHeader extends StatelessWidget {
  final String titulo;
  final int count;
  final String route;
  const _SectionHeader({required this.titulo, required this.count, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.verdeFondo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.verde)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.go(route),
            child: const Text(AppStrings.verTodas),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final DashboardSummaryModel resumen;
  const _SummaryGrid({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(AppStrings.nodosActivos, '${resumen.nodosActivos}/${resumen.totalNodos}', Icons.sensors_rounded, AppColors.verde),
      _SummaryItem(AppStrings.lotesEnProceso, '${resumen.lotesEnProceso}', Icons.inventory_2_rounded, AppColors.informacion),
      _SummaryItem(AppStrings.alertasActivas, '${resumen.alertasNoLeidas}', Icons.notifications_active_rounded,
          resumen.alertasNoLeidas > 0 ? AppColors.advertencia : AppColors.textoSecundario),
      _SummaryItem(AppStrings.produccionHoy, '${(resumen.totalKgProcesadosHoy / 1000).toStringAsFixed(1)}t', Icons.scale_rounded, AppColors.verde),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SummaryCard(item: items[0])),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(child: _SummaryCard(item: items[1])),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Row(
          children: [
            Expanded(child: _SummaryCard(item: items[2])),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(child: _SummaryCard(item: items[3])),
          ],
        ),
      ],
    );
  }
}

class _SummaryItem {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  const _SummaryItem(this.titulo, this.valor, this.icono, this.color);
}

class _SummaryCard extends StatelessWidget {
  final _SummaryItem item;
  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(item.icono, size: 18, color: item.color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.valor,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: item.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 22),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.titulo,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoteTile extends StatelessWidget {
  final BatchModel lote;
  const _LoteTile({required this.lote});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.informacionFondo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_rounded,
              size: 20, color: AppColors.informacion),
        ),
        title: Text(lote.codigo,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${lote.variedadNombre} • ${lote.siloNombre}',
            style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(lote.estado.displayName,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.informacion)),
            Text('${(lote.pesoKg / 1000).toStringAsFixed(1)}t',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textoSecundario)),
          ],
        ),
        onTap: () => context.push(RouteNames.detalleLotePath(lote.id)),
      ),
    );
  }
}

class _SilosRow extends StatelessWidget {
  final List<SiloModel> silos;
  const _SilosRow({required this.silos});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: silos.map((s) => _SiloChip(silo: s)).toList(),
      ),
    );
  }
}

class _SiloChip extends StatelessWidget {
  final SiloModel silo;
  const _SiloChip({required this.silo});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorSiloStatus(silo.estado);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(silo.nombre,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          Text(silo.estado.displayName,
              style: TextStyle(fontSize: 10, color: color.withAlpha(180))),
        ],
      ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  final AlertModel alerta;
  const _AlertaTile({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorAlertSeverity(alerta.severidad);
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: ListTile(
        leading: Icon(SensorUtils.iconAlertSeverity(alerta.severidad),
            color: color, size: 22),
        title: Text(alerta.mensaje,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${alerta.nodoNombre} • ${DateFormatter.tiempoTranscurrido(alerta.timestamp)}',
            style: const TextStyle(fontSize: 11)),
        trailing: alerta.leida
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.critico, shape: BoxShape.circle)),
        tileColor: alerta.leida ? null : color.withAlpha(8),
      ),
    );
  }
}

class _ShimmerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        const LoadingShimmer(width: 200, height: 28),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: const [
                Expanded(child: LoadingShimmer(width: double.infinity, height: 80)),
                SizedBox(width: 8),
                Expanded(child: LoadingShimmer(width: double.infinity, height: 80)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: LoadingShimmer(width: double.infinity, height: 80)),
                SizedBox(width: 8),
                Expanded(child: LoadingShimmer(width: double.infinity, height: 80)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
            3,
            (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LoadingShimmer(width: double.infinity, height: 72))),
      ],
    );
  }
}
