import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/batch_status.dart';
import '../../core/enums/producto_destino.dart';
import '../../core/router/route_names.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/sensor_utils.dart';
import '../../models/batch_estimation_model.dart';
import '../../models/batch_model.dart';
import '../../models/pending_event_model.dart';
import '../../models/volteo_model.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/sensor_chart_card.dart';
import '../../widgets/common/sync_status_button.dart';
import 'batch_event_dialogs.dart';

class BatchDetailScreen extends StatelessWidget {
  final String loteId;
  const BatchDetailScreen({super.key, required this.loteId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = sl<BatchProvider>();
        p.cargarLote(loteId);
        p.cargarLecturas(loteId);
        p.cargarVolteos(loteId);
        return p;
      },
      child: _BatchDetailView(loteId: loteId),
    );
  }
}

class _BatchDetailView extends StatelessWidget {
  final String loteId;
  const _BatchDetailView({required this.loteId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null && prov.loteSeleccionado == null) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error,
                onReintentar: () {
                  prov.cargarLote(loteId);
                  prov.cargarLecturas(loteId);
                }),
          );
        }
        final lote = prov.loteSeleccionado;
        if (lote == null) {
          return const Scaffold(
              appBar: OryzaFlowAppBar(
                  titulo: AppStrings.detalleLote, mostrarBotonAtras: true),
              body: EmptyStateWidget(mensaje: 'Lote no encontrado'));
        }

        // HU-010 (CA-010-02): estado del lote con los eventos registrados sin señal aplicados encima.
        final visual = prov.estadoVisual(lote);
        return Scaffold(
          appBar: OryzaFlowAppBar(
            titulo: lote.codigo,
            mostrarBotonAtras: true,
            acciones: const [SyncStatusButton()],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await prov.cargarLote(lote.id);
              await prov.cargarLecturas(lote.id);
              await prov.cargarVolteos(lote.id);
            },
            color: AppColors.verde,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                if (prov.desdeCache && prov.cacheGuardadoEn != null)
                  OfflineBanner(guardadoEn: prov.cacheGuardadoEn!),
                _StatusBanner(lote: lote, visual: visual),
                const SizedBox(height: AppDimensions.paddingM),
                if (visual.estado == BatchStatus.enProceso) ...[
                  _EstimacionSection(lote: lote),
                  const SizedBox(height: AppDimensions.paddingM),
                ],
                _InfoSection(lote: lote),
                const SizedBox(height: AppDimensions.paddingM),
                _ControlSection(lote: lote, prov: prov, visual: visual),
                const SizedBox(height: AppDimensions.paddingM),
                _VolteosSection(volteos: prov.volteos),
                const SizedBox(height: AppDimensions.paddingM),
                Text(AppStrings.lecturasDelLote,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.paddingS),
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
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final BatchModel lote;
  final EstadoLoteVisual visual;
  const _StatusBanner({required this.lote, required this.visual});

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorBatchStatus(visual.estado);
    final titulo = visual.recogidaPendiente
        ? '${visual.estado.displayName} (${AppStrings.pendienteSincronizar})'
        : visual.estado.displayName;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: color)),
                if (lote.alertasNoLeidas > 0)
                  Text('${lote.alertasNoLeidas} alerta(s) sin atender',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.advertencia)),
                if (visual.coberturaPendiente != null)
                  Text(
                      visual.coberturaPendiente == TipoEvento.cubrir
                          ? 'Cubierto (pendiente)'
                          : 'Descubierto (pendiente)',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.advertencia)),
                if (visual.errores > 0)
                  InkWell(
                    onTap: () => context.push(RouteNames.sincronizacion),
                    child: Text(
                        '${visual.errores} evento(s) con error — ver ${AppStrings.sincronizacion}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.critico,
                            decoration: TextDecoration.underline)),
                  ),
              ],
            ),
          ),
          if (lote.duracion != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Duración',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textoSecundario)),
                Text(
                    '${lote.duracion!.inHours}h ${lote.duracion!.inMinutes.remainder(60)}min',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: color)),
              ],
            ),
        ],
      ),
    );
  }
}

/// HU-001 (CA-001-02), HU-003 (CA-003-01/02) y HU-013 (CA-013-02): humedad estimada con su hora, etiqueta de
/// dato desactualizado, horas restantes y hora proyectada de fin, «No llegará a la meta hoy» y «Por verificar».
/// Las banderas las calcula el backend; la app no recalcula la antigüedad.
class _EstimacionSection extends StatelessWidget {
  final BatchModel lote;
  const _EstimacionSection({required this.lote});

  @override
  Widget build(BuildContext context) {
    final est = lote.estimacion;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(AppStrings.estimacionActual,
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (lote.porVerificar) _Chip(
                  texto: lote.ultimaDiferenciaPp != null
                      ? '${AppStrings.porVerificar} (Δ ${lote.ultimaDiferenciaPp!.abs().toStringAsFixed(1)} pp)'
                      : AppStrings.porVerificar,
                  color: AppColors.advertencia,
                  icono: Icons.rule_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (est == null)
              const Text(AppStrings.sinEstimacion,
                  style: TextStyle(fontSize: 13, color: AppColors.textoSecundario))
            else
              _EstimacionBody(est: est, meta: lote.metaObjetivo ?? lote.metaDeclarada),
          ],
        ),
      ),
    );
  }
}

class _EstimacionBody extends StatelessWidget {
  final BatchEstimationModel est;
  final double? meta;
  const _EstimacionBody({required this.est, required this.meta});

  @override
  Widget build(BuildContext context) {
    final stale = est.desactualizada;
    final valorColor = stale ? AppColors.textoSecundario : AppColors.chartHumedadGrano;
    final hum = est.humedadGrano;
    final metaLote = meta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(hum != null ? '${hum.toStringAsFixed(1)} %' : '—',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: valorColor,
                    decoration: stale ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textoSecundario)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.humedadEstimada,
                      style: TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                  Text(
                    // CA-001-02: siempre con su hora; si es viejo, "último valor conocido", no actual.
                    stale
                        ? 'Último valor conocido: ${DateFormatter.relativo(est.ts)}'
                        : 'Actualizado ${DateFormatter.hora(est.ts)}'
                            '${est.segmento != null ? ' · segmento ${est.segmento}' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                  ),
                  if (meta != null)
                    Text('Meta: ${meta!.toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                ],
              ),
            ),
          ],
        ),
        if (stale) ...[
          const SizedBox(height: 10),
          _Aviso(
            texto: AppStrings.datoDesactualizado,
            detalle: 'Sin publicaciones nuevas desde ${DateFormatter.fechaHora(est.ts)} '
                '(más de ${(est.umbralDesactualizadoSegundos / 60).round()} min)',
            color: AppColors.advertencia,
            icono: Icons.history_toggle_off_rounded,
          ),
        ],
        const SizedBox(height: 12),
        // CA-003-01 / CA-003-02: horas restantes y hora proyectada, o "No llegará a la meta hoy".
        if (est.noLlegaHoy)
          _Aviso(
            texto: AppStrings.noLlegaraHoy,
            detalle: est.restante != null
                ? 'Faltan ${DateFormatter.duracion(est.restante!)} de sol; la jornada termina a las ${est.finJornada}. '
                    'Cubra el lote por el sereno y continúe mañana.'
                : 'La jornada termina a las ${est.finJornada}.',
            color: AppColors.informacion,
            icono: Icons.nights_stay_rounded,
          )
        else if (est.tieneProyeccion)
          Row(
            children: [
              Expanded(
                child: _Dato(
                  label: 'Tiempo restante',
                  valor: 'Faltan ${DateFormatter.duracion(est.restante!)}',
                  icono: Icons.timer_outlined,
                  atenuado: stale,
                ),
              ),
              Expanded(
                child: _Dato(
                  label: AppStrings.finEstimado,
                  valor: DateFormatter.hora(est.finEstimado!),
                  icono: Icons.flag_outlined,
                  atenuado: stale,
                ),
              ),
            ],
          )
        else
          _Dato(
            label: 'Tiempo restante',
            valor: (hum != null && metaLote != null && hum <= metaLote + 0.5)
                ? 'Meta alcanzada'
                : 'Sin proyección (meta no alcanzable con el aire actual)',
            icono: Icons.timer_off_outlined,
            atenuado: stale,
          ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final String texto;
  final String detalle;
  final Color color;
  final IconData icono;
  const _Aviso({required this.texto, required this.detalle, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
                const SizedBox(height: 2),
                Text(detalle, style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final bool atenuado;
  const _Dato({required this.label, required this.valor, required this.icono, this.atenuado = false});

  @override
  Widget build(BuildContext context) {
    final color = atenuado ? AppColors.textoSecundario : AppColors.textoPrimario;
    return Row(
      children: [
        Icon(icono, size: 18, color: AppColors.textoSecundario),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
              Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icono;
  const _Chip({required this.texto, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final BatchModel lote;
  const _InfoSection({required this.lote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del Lote',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            _Row('Variedad', lote.variedadNombre),
            if (lote.producto != null)
              _Row(AppStrings.destinoComercial, lote.producto!.displayName),
            if (lote.metaDeclarada != null)
              _Row('Meta declarada', '${lote.metaDeclarada!.toStringAsFixed(1)} %')
            else if (lote.metaObjetivo != null)
              _Row('Meta (perfil)', '${lote.metaObjetivo!.toStringAsFixed(1)} %'),
            if (lote.duenoCodigo != null && lote.duenoCodigo!.isNotEmpty)
              _Row('Dueño', lote.duenoCodigo!),
            _Row('Silo', lote.siloNombre),
            _Row('Nodo', lote.nodoNombre),
            _Row('Perfil de secado', lote.perfilSecadoNombre),
            _Row('Peso', '${(lote.pesoKg / 1000).toStringAsFixed(2)} t'),
            _Row('Humedad inicial',
                '${lote.humedadInicial.toStringAsFixed(1)} %'),
            if (lote.humedadFinal != null)
              _Row('Humedad final',
                  '${lote.humedadFinal!.toStringAsFixed(1)} %'),
            _Row('Ingreso', DateFormatter.fechaHora(lote.fechaIngreso)),
            if (lote.fechaInicio != null)
              _Row('Inicio secado',
                  DateFormatter.fechaHora(lote.fechaInicio!)),
            if (lote.fechaFin != null)
              _Row('Fin secado',
                  DateFormatter.fechaHora(lote.fechaFin!)),
            _Row('Operador', lote.operadorNombre),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String valor;
  const _Row(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textoSecundario)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  final BatchModel lote;
  final BatchProvider prov;
  final EstadoLoteVisual visual;
  const _ControlSection(
      {required this.lote, required this.prov, required this.visual});

  @override
  Widget build(BuildContext context) {
    final cerrado = visual.estado == BatchStatus.completado ||
        visual.estado == BatchStatus.cancelado;
    final ocupado = prov.estaProcesando;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Control de Secado',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            if (lote.estado == BatchStatus.pendiente) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // Iniciar aprovisiona el nodo: requiere conexión, no se encola.
                  onPressed: (ocupado || !prov.hayRed)
                      ? null
                      : () async {
                          final ok = await prov.iniciarSecado(lote.id);
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(prov.error ?? 'Error'),
                                  backgroundColor: AppColors.critico),
                            );
                          }
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(AppStrings.iniciarSecado),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white),
                ),
              ),
              if (!prov.hayRed)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(AppStrings.requiereConexion,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textoSecundario)),
                ),
            ],
            if (visual.estado == BatchStatus.enProceso) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: ocupado ? null : () => _detener(context),
                  icon: const Icon(Icons.stop_rounded,
                      color: AppColors.critico),
                  label: const Text(AppStrings.detenerSecado,
                      style: TextStyle(color: AppColors.critico)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.critico)),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: ocupado ? null : () => _confirmarVolteo(context),
                  icon: const Icon(Icons.autorenew_rounded),
                  label: const Text(AppStrings.registrarVolteo),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              // F3: cubrir cierra el tramo (NOCHE/LLUVIA); descubrir abre el siguiente con la M0 del PM-410.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (ocupado || visual.cubierto == true)
                          ? null
                          : () => _cubrir(context),
                      icon: const Icon(Icons.nights_stay_rounded),
                      label: const Text(AppStrings.cubrirLote),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (ocupado || visual.cubierto == false)
                          ? null
                          : () => _descubrir(context),
                      icon: const Icon(Icons.wb_sunny_rounded),
                      label: const Text(AppStrings.descubrirLote),
                    ),
                  ),
                ],
              ),
            ],
            // HU-013: lecturas del medidor y pares (también en lotes cerrados: las planillas se cargan después).
            if (lote.estado != BatchStatus.pendiente) ...[
              const SizedBox(height: AppDimensions.paddingS),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(RouteNames.lecturasLotePath(lote.id)),
                  icon: const Icon(Icons.straighten_rounded),
                  label: Text(cerrado ? '${AppStrings.lecturasMedidor} (historial)' : AppStrings.lecturasMedidor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// CA-010-02: enviado (verde), guardado sin señal (neutro, con su hora, sin pedir reingreso) o rechazado (rojo).
  Future<void> _manejar(BuildContext context,
      Future<ResultadoRegistro> Function() accion, TipoEvento tipo) async {
    final r = await accion();
    if (!context.mounted) return;
    final msgr = ScaffoldMessenger.of(context);
    switch (r) {
      case Enviado(:final ts):
        msgr.showSnackBar(SnackBar(
          content: Text(tipo.mensajeEnviado(DateFormatter.hora(ts.toLocal()))),
          backgroundColor: AppColors.verde,
        ));
      case Encolado(:final evento):
        msgr.showSnackBar(SnackBar(
          content: Text(tipo.mensajeGuardadoOffline(
              DateFormatter.hora(evento.ts.toLocal()))),
          duration: const Duration(seconds: 5),
        ));
      case Rechazado(:final mensaje):
        msgr.showSnackBar(SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColors.critico,
        ));
    }
  }

  Future<void> _confirmarVolteo(BuildContext context) async {
    final ok = await mostrarDialogoConfirmacion(
      context: context,
      titulo: AppStrings.volteoManual,
      mensaje:
          'Registrar un volteo manual del grano del lote "${lote.codigo}". '
          'Esta acción la decide y ejecuta el operario (volteo con rastrillo); '
          'el sistema solo registra el método y la hora.',
      textoCancelar: 'Cancelar',
      textoConfirmar: 'Registrar',
    );
    if (ok != true || !context.mounted) return;
    await _manejar(
        context, () => prov.registrarVolteo(lote.id), TipoEvento.volteo);
  }

  Future<void> _cubrir(BuildContext context) async {
    final motivo =
        await mostrarDialogoCubrir(context, codigoLote: lote.codigo);
    if (motivo == null || !context.mounted) return;
    await _manejar(
        context, () => prov.cubrirLote(lote.id, motivo), TipoEvento.cubrir);
  }

  Future<void> _descubrir(BuildContext context) async {
    final m0 = await mostrarDialogoDescubrir(context, codigoLote: lote.codigo);
    if (m0 == null || !context.mounted) return;
    await _manejar(
        context, () => prov.descubrirLote(lote.id, m0), TipoEvento.descubrir);
  }

  Future<void> _detener(BuildContext context) async {
    final r = await mostrarDialogoDetener(context, codigoLote: lote.codigo);
    if (r == null || !context.mounted) return;
    await _manejar(
        context,
        () => prov.detenerSecado(lote.id, humedadFinal: r.humedadFinal),
        TipoEvento.recoger);
  }
}

/// Volteos del lote con su hora (servidor + registrados sin señal, HU-010).
class _VolteosSection extends StatelessWidget {
  final List<VolteoModel> volteos;
  const _VolteosSection({required this.volteos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.volteos,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingS),
            if (volteos.isEmpty)
              const Text(AppStrings.sinVolteos,
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textoSecundario))
            else
              for (final v in volteos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.autorenew_rounded,
                          size: 18, color: AppColors.textoSecundario),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(DateFormatter.fechaHora(v.timestamp),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      if (v.pendiente)
                        const _Chip(
                            texto: AppStrings.pendienteSincronizar,
                            color: AppColors.advertencia,
                            icono: Icons.cloud_upload_outlined),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
