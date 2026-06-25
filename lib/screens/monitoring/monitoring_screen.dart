import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/node_status.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/node_model.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/status_indicator.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MonitoringProvider>()..cargarNodos(),
      child: const _MonitoringView(),
    );
  }
}

class _MonitoringView extends StatelessWidget {
  const _MonitoringView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.monitoreo,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        acciones: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: AppStrings.parametros,
            onPressed: () => context.push(RouteNames.parametros),
          ),
        ],
      ),
      body: Consumer<MonitoringProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarNodos);
          }
          if (prov.nodos.isEmpty) {
            return const EmptyStateWidget(
                icono: Icons.sensors_off_rounded,
                mensaje: 'Sin nodos registrados');
          }

          return RefreshIndicator(
            onRefresh: prov.cargarNodos,
            color: AppColors.verde,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: prov.nodos.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) => _NodeCard(nodo: prov.nodos[i], prov: prov),
            ),
          );
        },
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final NodeModel nodo;
  final MonitoringProvider prov;
  const _NodeCard({required this.nodo, required this.prov});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorNodeStatus(nodo.estado);
    final activo = nodo.estado == NodeStatus.activo ||
        nodo.estado == NodeStatus.alerta;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        onTap: () => context.push(
            '${RouteNames.configEsp32}?nodo=${nodo.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusIndicator(estado: nodo.estado),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nodo.nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        Text(nodo.ubicacion,
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
                    child: Text(nodo.estado.displayName,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ],
              ),
              if (activo) ...[
                const SizedBox(height: 12),
                _ReadingsGrid(nodo: nodo),
                const SizedBox(height: 8),
                Text(
                    'Actualizado: ${DateFormatter.tiempoTranscurrido(nodo.ultimaActualizacion)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textoSecundario)),
                const SizedBox(height: 6),
                const Divider(height: 1),
                _VolteoAction(nodo: nodo, prov: prov),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingsGrid extends StatelessWidget {
  final NodeModel nodo;
  const _ReadingsGrid({required this.nodo});

  @override
  Widget build(BuildContext context) {
    final readings = [
      (Icons.thermostat_rounded, AppColors.chartTemperatura,
          '${nodo.temperatura.toStringAsFixed(1)}°C', 'Temperatura'),
      (Icons.water_drop_outlined, AppColors.chartHumedad,
          '${nodo.humedad.toStringAsFixed(1)}%', 'Humedad'),
      (Icons.grass_rounded, AppColors.chartHumedadGrano,
          '${nodo.humedadGrano.toStringAsFixed(1)}%', 'H. Grano'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: readings.map((r) => _ReadingTile(
            icon: r.$1,
            color: r.$2,
            value: r.$3,
            label: r.$4,
          )).toList(),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _ReadingTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textoSecundario),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VolteoAction extends StatelessWidget {
  final NodeModel nodo;
  final MonitoringProvider prov;
  const _VolteoAction({required this.nodo, required this.prov});

  @override
  Widget build(BuildContext context) {
    final ultimo = prov.ultimoVolteo(nodo.id);
    return Row(
      children: [
        Expanded(
          child: Text(
            ultimo == null
                ? 'Sin volteos registrados'
                : 'Último volteo: ${DateFormatter.fechaHora(ultimo.timestamp)} (manual)',
            style: const TextStyle(
                fontSize: 10, color: AppColors.textoSecundario),
          ),
        ),
        TextButton.icon(
          onPressed: prov.estaProcesando ? null : () => _confirmar(context),
          icon: const Icon(Icons.autorenew_rounded, size: 16),
          label: const Text(AppStrings.registrarVolteo),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.volteoManual),
        content: Text(
          'Registrar un volteo manual del grano en "${nodo.nombre}". '
          'Esta acción la decide y ejecuta el operario (volteo con rastrillo); '
          'el sistema solo registra el método y la hora.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final exito = await prov.registrarVolteo(nodo.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito
            ? 'Volteo manual registrado'
            : (prov.error ?? 'No se pudo registrar el volteo')),
        backgroundColor: exito ? AppColors.verde : AppColors.critico,
      ),
    );
  }
}
