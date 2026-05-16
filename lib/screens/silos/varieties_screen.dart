import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/route_names.dart';
import '../../models/variety_model.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class VarietiesScreen extends StatelessWidget {
  const VarietiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SiloProvider>()..cargarVariedades(),
      child: const _VarietiesView(),
    );
  }
}

class _VarietiesView extends StatelessWidget {
  const _VarietiesView();

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthProvider>().usuario?.rol;
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.variedades,
        mostrarBotonAtras: true,
      ),
      floatingActionButton: rol?.puedeEditarPerfiles == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.editarVariedad),
              backgroundColor: AppColors.verde,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(AppStrings.nuevaVariedad,
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      body: Consumer<SiloProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarVariedades);
          }
          if (prov.variedades.isEmpty) {
            return const EmptyStateWidget(
                icono: Icons.grass_rounded,
                mensaje: 'Sin variedades registradas');
          }

          return RefreshIndicator(
            onRefresh: prov.cargarVariedades,
            color: AppColors.verde,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: prov.variedades.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) => _VarietyCard(
                variedad: prov.variedades[i],
                puedeEditar: rol?.puedeEditarPerfiles == true,
                puedeEliminar: rol?.puedeCrearPerfiles == true,
                onEditar: () => context.push(
                    '${RouteNames.editarVariedad}?id=${prov.variedades[i].id}'),
                onEliminar: () async {
                  final confirmar = await mostrarDialogoConfirmacion(
                    context: context,
                    titulo: AppStrings.confirmarEliminar,
                    mensaje: AppStrings.accionIrreversible,
                    esDestructivo: true,
                  );
                  if (confirmar == true && context.mounted) {
                    await prov.eliminarVariedad(prov.variedades[i].id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VarietyCard extends StatelessWidget {
  final VarietyModel variedad;
  final bool puedeEditar;
  final bool puedeEliminar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _VarietyCard({
    required this.variedad,
    required this.puedeEditar,
    required this.puedeEliminar,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    color: AppColors.verdeFondo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grass_rounded,
                      size: 20, color: AppColors.verde),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(variedad.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      if (variedad.descripcion.isNotEmpty)
                        Text(variedad.descripcion,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textoSecundario),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (puedeEditar)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEditar,
                    color: AppColors.textoSecundario,
                  ),
                if (puedeEliminar)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onEliminar,
                    color: AppColors.critico,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Chip(
                    label:
                        'H. objetivo: ${variedad.humedadObjetivo.toStringAsFixed(1)}%'),
                _Chip(
                    label:
                        'Temp. máx: ${variedad.temperaturaMaxima.toStringAsFixed(0)}°C'),
                _Chip(
                    label:
                        'Tiempo est.: ${variedad.tiempoEstimadoHoras}h'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.verdeFondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.verde)),
    );
  }
}
