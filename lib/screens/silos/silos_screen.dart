import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/silo_model.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class SilosScreen extends StatelessWidget {
  const SilosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SiloProvider>()..cargarSilos(),
      child: const _SilosView(),
    );
  }
}

class _SilosView extends StatefulWidget {
  const _SilosView();

  @override
  State<_SilosView> createState() => _SilosViewState();
}

class _SilosViewState extends State<_SilosView> {
  SiloStatus? _filtro;

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthProvider>().usuario?.rol;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.silos,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        acciones: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: AppStrings.variedades,
            onPressed: () => context.push(RouteNames.variedades),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: AppStrings.disponibilidad,
            onPressed: () => context.push(RouteNames.disponibilidad),
          ),
        ],
      ),
      floatingActionButton: rol?.puedeGestionarNodos == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.editarSilo),
              backgroundColor: cs.primary,
              icon: Icon(Icons.add, color: cs.onPrimary),
              label: Text(AppStrings.nuevoSilo,
                  style: TextStyle(color: cs.onPrimary)),
            )
          : null,
      body: Column(
        children: [
          _SiloFiltroBarra(
            filtro: _filtro,
            onChange: (f) => setState(() => _filtro = f),
          ),
          Expanded(
            child: Consumer<SiloProvider>(
              builder: (_, prov, __) {
                if (prov.estaCargando) return const ShimmerList();
                if (prov.error != null) {
                  return ErrorStateWidget(
                      mensaje: prov.error, onReintentar: prov.cargarSilos);
                }

                final silos = _filtro == null
                    ? prov.silos
                    : prov.silos.where((s) => s.estado == _filtro).toList();

                if (silos.isEmpty) {
                  return const EmptyStateWidget(
                      icono: Icons.warehouse_outlined,
                      mensaje: 'Sin silos registrados');
                }

                return RefreshIndicator(
                  onRefresh: prov.cargarSilos,
                  color: cs.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: silos.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.paddingS),
                    itemBuilder: (_, i) => _SiloCard(
                      silo: silos[i],
                      puedeEditar: rol?.puedeGestionarNodos == true,
                      onEditar: () => context.push(
                          RouteNames.editarSilo, extra: silos[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SiloFiltroBarra extends StatelessWidget {
  final SiloStatus? filtro;
  final ValueChanged<SiloStatus?> onChange;
  const _SiloFiltroBarra({required this.filtro, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const opciones = [
      (null, 'Todos'),
      (SiloStatus.disponible, 'Disponibles'),
      (SiloStatus.ocupado, 'En uso'),
      (SiloStatus.mantenimiento, 'Mantenimiento'),
    ];
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      color: cs.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM, vertical: 6),
        children: opciones.map((op) {
          final selected = filtro == op.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(op.$2),
              selected: selected,
              onSelected: (_) => onChange(op.$1),
              selectedColor: cs.primary.withAlpha(30),
              checkmarkColor: cs.primary,
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected ? cs.primary : cs.onSurface.withAlpha(130)),
              side: BorderSide(color: selected ? cs.primary : cs.outline),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SiloCard extends StatelessWidget {
  final SiloModel silo;
  final bool puedeEditar;
  final VoidCallback onEditar;
  const _SiloCard(
      {required this.silo,
      required this.puedeEditar,
      required this.onEditar});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorSiloStatus(silo.estado);
    final pct = silo.porcentajeOcupacion;

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
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warehouse_rounded, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(silo.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(silo.ubicacion,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(130))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withAlpha(60)),
                  ),
                  child: Text(silo.estado.displayName,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
                if (puedeEditar) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEditar,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Capacidad: ${silo.capacidadToneladas.toStringAsFixed(0)}t',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(130))),
                Text(
                    'Ocupación: ${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Theme.of(context).colorScheme.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}
