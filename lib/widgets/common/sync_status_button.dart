import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/route_names.dart';
import '../../core/sync/sync_service.dart';

/// Indicador de la cola de eventos sin señal (HU-010, CA-010-02): cuántos esperan o fallaron.
/// Lleva a la pantalla de sincronización.
class SyncStatusButton extends StatelessWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final n = sync.pendientes + sync.conError;
    final IconData icono;
    Color? color;
    if (sync.conError > 0) {
      icono = Icons.sync_problem_rounded;
      color = AppColors.advertencia;
    } else if (!sync.hayRed) {
      icono = Icons.cloud_off_outlined;
    } else {
      icono = Icons.cloud_upload_outlined;
    }
    return IconButton(
      tooltip: n > 0
          ? '$n evento${n == 1 ? '' : 's'} pendiente${n == 1 ? '' : 's'} de sincronizar'
          : 'Sincronización',
      onPressed: () => context.push(RouteNames.sincronizacion),
      icon: Badge(
        isLabelVisible: n > 0,
        label: Text('$n'),
        child: Icon(icono, color: color),
      ),
    );
  }
}
