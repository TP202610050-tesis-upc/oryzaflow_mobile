import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/pending_event_model.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

/// Cola de eventos registrados sin señal (HU-010, CA-010-02): pendientes, con error y sincronizados.
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final eventos = sync.eventos;
    final errores = eventos.where((e) => e.estado == EstadoEvento.error).toList();
    final pendientes = eventos
        .where((e) => e.estado == EstadoEvento.pendiente || e.estado == EstadoEvento.enviando)
        .toList();
    final hechos = eventos.where((e) => e.estado == EstadoEvento.sincronizado).toList()
      ..sort((a, b) => (b.sincronizadoEn ?? b.ts).compareTo(a.sincronizadoEn ?? a.ts));
    final puedeSincronizar = sync.hayRed && !sync.sincronizando && sync.pendientes > 0;

    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.sincronizacion,
        mostrarBotonAtras: true,
        acciones: [
          TextButton.icon(
            onPressed: puedeSincronizar ? sync.sincronizar : null,
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text(AppStrings.sincronizarAhora),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!sync.hayRed)
            Container(
              width: double.infinity,
              color: AppColors.advertenciaFondo,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
              child: const Text(AppStrings.offlineSeEnviaran,
                  style: TextStyle(fontSize: 12, color: AppColors.advertencia)),
            ),
          if (sync.sincronizando) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: eventos.isEmpty
                ? const EmptyStateWidget(
                    icono: Icons.cloud_done_outlined,
                    mensaje: AppStrings.sinEventosPendientes)
                : ListView(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    children: [
                      if (errores.isNotEmpty) ...[
                        _Titulo(AppStrings.errores, color: AppColors.critico),
                        for (final e in errores) _EventoTile(evento: e, sync: sync),
                      ],
                      if (pendientes.isNotEmpty) ...[
                        _Titulo(AppStrings.pendientes),
                        for (final e in pendientes) _EventoTile(evento: e, sync: sync),
                      ],
                      if (hechos.isNotEmpty) ...[
                        _Titulo(AppStrings.sincronizadosRecientes, color: AppColors.verde),
                        for (final e in hechos) _EventoTile(evento: e, sync: sync),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  final Color? color;
  const _Titulo(this.texto, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.paddingS, bottom: AppDimensions.paddingS),
      child: Text(texto,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
    );
  }
}

class _EventoTile extends StatelessWidget {
  final PendingEvent evento;
  final SyncService sync;
  const _EventoTile({required this.evento, required this.sync});

  Color get _colorEstado => switch (evento.estado) {
        EstadoEvento.error => AppColors.critico,
        EstadoEvento.sincronizado => AppColors.verde,
        EstadoEvento.enviando => AppColors.informacion,
        EstadoEvento.pendiente => AppColors.advertencia,
      };

  Future<void> _descartar(BuildContext context) async {
    final ok = await mostrarDialogoConfirmacion(
      context: context,
      titulo: AppStrings.descartarEvento,
      mensaje: AppStrings.descartarEventoMensaje,
      textoConfirmar: AppStrings.descartar,
      esDestructivo: true,
    );
    if (ok == true) await sync.descartar(evento.id);
  }

  @override
  Widget build(BuildContext context) {
    final e = evento;
    final esError = e.estado == EstadoEvento.error;
    final esPendiente = e.estado == EstadoEvento.pendiente;
    return Card(
      child: ListTile(
        leading: Icon(e.tipo.icono, color: _colorEstado),
        title: Text('${e.tipo.displayName} · ${e.loteCodigo}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${DateFormatter.fechaHora(e.ts.toLocal())} · ${e.estado.displayName}',
                style: TextStyle(fontSize: 12, color: _colorEstado)),
            if (e.intentos > 0)
              Text('${AppStrings.intentos}: ${e.intentos}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
            if (esError && e.ultimoError != null)
              Text(e.ultimoError!,
                  style: const TextStyle(fontSize: 12, color: AppColors.critico)),
          ],
        ),
        isThreeLine: esError && e.ultimoError != null,
        trailing: (esError || esPendiente)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esError)
                    TextButton(
                      onPressed: () => sync.reintentar(e.id),
                      child: const Text(AppStrings.reintentar),
                    ),
                  IconButton(
                    tooltip: AppStrings.descartar,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _descartar(context),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
