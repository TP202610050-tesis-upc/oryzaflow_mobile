import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/node_status.dart';
import '../../models/node_model.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class FieldControlScreen extends StatelessWidget {
  const FieldControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MonitoringProvider>()..cargarNodos(),
      child: const _FieldControlView(),
    );
  }
}

class _FieldControlView extends StatelessWidget {
  const _FieldControlView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OryzaFlowAppBar(
        titulo: AppStrings.controlDeCampo,
        mostrarBotonAtras: true,
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
                mensaje: 'Sin nodos disponibles');
          }

          return RefreshIndicator(
            onRefresh: prov.cargarNodos,
            color: AppColors.verde,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: prov.nodos.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) => _NodeControlCard(
                nodo: prov.nodos[i],
                prov: prov,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NodeControlCard extends StatelessWidget {
  final NodeModel nodo;
  final MonitoringProvider prov;
  const _NodeControlCard({required this.nodo, required this.prov});

  @override
  Widget build(BuildContext context) {
    final activo = nodo.estado == NodeStatus.activo ||
        nodo.estado == NodeStatus.alerta;
    final ventilador = prov.ventiladorActivo(nodo.id);
    final calefactor = prov.calefactorActivo(nodo.id);
    final manual = prov.esModoManual(nodo.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activo ? AppColors.verde : AppColors.textoSecundario,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(nodo.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Text(nodo.ubicacion,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textoSecundario)),
              ],
            ),
            const Divider(height: 20),
            if (!activo)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.borde,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.textoSecundario),
                    SizedBox(width: 8),
                    Text('Nodo inactivo — control deshabilitado',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textoSecundario)),
                  ],
                ),
              )
            else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    const Icon(Icons.air_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(AppStrings.ventilador),
                  ],
                ),
                subtitle: Text(ventilador ? 'Encendido' : 'Apagado',
                    style: TextStyle(
                        color: ventilador
                            ? AppColors.verde
                            : AppColors.textoSecundario)),
                value: ventilador,
                onChanged: manual
                    ? (_) => prov.toggleVentilador(nodo.id)
                    : null,
                activeThumbColor: AppColors.verde,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(AppStrings.calefactor),
                  ],
                ),
                subtitle: Text(calefactor ? 'Encendido' : 'Apagado',
                    style: TextStyle(
                        color: calefactor
                            ? AppColors.advertencia
                            : AppColors.textoSecundario)),
                value: calefactor,
                onChanged: manual
                    ? (_) => prov.toggleCalefactor(nodo.id)
                    : null,
                activeThumbColor: AppColors.advertencia,
              ),
              const Divider(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    const Icon(Icons.settings_remote_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(AppStrings.modoManual),
                  ],
                ),
                subtitle: Text(
                    manual
                        ? AppStrings.modoManual
                        : AppStrings.modoAutomatico,
                    style: TextStyle(
                        color: manual
                            ? AppColors.informacion
                            : AppColors.textoSecundario)),
                value: manual,
                onChanged: (_) => prov.toggleModoManual(nodo.id),
                activeThumbColor: AppColors.informacion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
