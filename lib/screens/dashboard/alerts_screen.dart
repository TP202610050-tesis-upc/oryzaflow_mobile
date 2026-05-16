import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/alert_severity.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/alert_model.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with WidgetsBindingObserver {
  AlertSeverity? _filtroSeveridad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().cargarAlertas();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AlertProvider>().cargarAlertas(silencioso: true);
    }
  }

  Future<void> _marcarLeida(AlertProvider prov, String id) async {
    final ok = await prov.marcarLeida(id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo marcar como leída')),
      );
    }
  }

  Future<void> _eliminar(AlertProvider prov, AlertModel alerta) async {
    await prov.eliminarAlerta(alerta.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notificación eliminada'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => prov.restaurarAlerta(alerta),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.alertas,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        acciones: [
          Consumer<AlertProvider>(
            builder: (_, prov, __) => prov.cantidadNoLeidas > 0
                ? TextButton(
                    onPressed: prov.estaProcesando ? null : prov.marcarTodasLeidas,
                    child: const Text(AppStrings.marcarTodasLeidas,
                        style: TextStyle(fontSize: 12)),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltroBarra(
              filtro: _filtroSeveridad,
              onChange: (f) => setState(() => _filtroSeveridad = f)),
          Expanded(
            child: Consumer<AlertProvider>(
              builder: (_, prov, __) {
                if (prov.estaCargando) return const ShimmerList();
                if (prov.error != null) {
                  return ErrorStateWidget(
                      mensaje: prov.error, onReintentar: prov.cargarAlertas);
                }

                final alertas = _filtroSeveridad == null
                    ? prov.alertas
                    : prov.alertas
                        .where((a) => a.severidad == _filtroSeveridad)
                        .toList();

                if (alertas.isEmpty) {
                  return const EmptyStateWidget(
                    mensaje: AppStrings.todasLeidas,
                    icono: Icons.notifications_none_rounded,
                  );
                }

                final noLeidas = alertas.where((a) => !a.leida).toList();
                final leidas = alertas.where((a) => a.leida).toList();

                return RefreshIndicator(
                  onRefresh: prov.cargarAlertas,
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM),
                    children: [
                      if (noLeidas.isNotEmpty) ...[
                        _SeccionHeader(
                          titulo: 'Sin leer',
                          cantidad: noLeidas.length,
                        ),
                        ...noLeidas.map((a) => _AlertTile(
                              alerta: a,
                              onMarcarLeida: () => _marcarLeida(prov, a.id),
                              onEliminar: () => _eliminar(prov, a),
                            )),
                        const SizedBox(height: 8),
                      ],
                      if (leidas.isNotEmpty) ...[
                        _SeccionHeader(titulo: 'Anteriores'),
                        ...leidas.map((a) => _AlertTile(
                              alerta: a,
                              onMarcarLeida: null,
                              onEliminar: () => _eliminar(prov, a),
                            )),
                      ],
                    ],
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

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final int? cantidad;
  const _SeccionHeader({required this.titulo, this.cantidad});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Text(
            titulo.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                color: cs.onSurface.withAlpha(140)),
          ),
          if (cantidad != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$cantidad',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertModel alerta;
  final VoidCallback? onMarcarLeida;
  final VoidCallback onEliminar;

  const _AlertTile({
    required this.alerta,
    required this.onMarcarLeida,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorAlertSeverity(alerta.severidad);
    final cs = Theme.of(context).colorScheme;
    final leida = alerta.leida;

    return Dismissible(
      key: ValueKey(alerta.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Eliminar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      onDismissed: (_) => onEliminar(),
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM, vertical: 3),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        shape: BoxShape.circle),
                    child: Icon(
                        SensorUtils.iconAlertSeverity(alerta.severidad),
                        size: 17,
                        color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(alerta.severidad.displayName,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: color)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.tiempoTranscurrido(
                                  alerta.timestamp),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withAlpha(110)),
                            ),
                            if (!leida) ...[
                              const Spacer(),
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          alerta.mensaje,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: leida
                                  ? FontWeight.w400
                                  : FontWeight.w500),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.sensors_rounded,
                                size: 11,
                                color: cs.onSurface.withAlpha(100)),
                            const SizedBox(width: 3),
                            Text(alerta.nodoNombre,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface.withAlpha(120))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onMarcarLeida != null
                      ? IconButton(
                          icon: const Icon(Icons.done_rounded, size: 18),
                          color: cs.primary,
                          tooltip: AppStrings.marcarLeida,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                          onPressed: onMarcarLeida,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: Icon(Icons.check_circle_outline_rounded,
                              size: 18,
                              color: cs.onSurface.withAlpha(50)),
                        ),
                ],
              ),
            ),
          ),
          // Left color indicator
          Positioned(
            left: AppDimensions.paddingM,
            top: 3,
            bottom: 3,
            child: Container(
              width: leida ? 3 : 4,
              decoration: BoxDecoration(
                color: color.withAlpha(leida ? 120 : 255),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusM),
                  bottomLeft: Radius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroBarra extends StatelessWidget {
  final AlertSeverity? filtro;
  final ValueChanged<AlertSeverity?> onChange;
  const _FiltroBarra({required this.filtro, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const opciones = [
      (null, 'Todas'),
      (AlertSeverity.critica, 'Críticas'),
      (AlertSeverity.advertencia, 'Advertencias'),
      (AlertSeverity.informacion, 'Información'),
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
