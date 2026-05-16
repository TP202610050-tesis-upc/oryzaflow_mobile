import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class ExportReportScreen extends StatelessWidget {
  const ExportReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ReportProvider>(),
      child: const _ExportView(),
    );
  }
}

class _ExportView extends StatefulWidget {
  const _ExportView();

  @override
  State<_ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends State<_ExportView> {
  String _formato = 'PDF';

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (_, prov, __) {
        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.exportarReporte,
            mostrarBotonAtras: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.download_rounded,
                  size: 56, color: AppColors.verde),
              const SizedBox(height: 16),
              Text(
                'Selecciona el rango de fechas y el formato del reporte',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textoSecundario),
              ),
              const SizedBox(height: 32),
              Text('Rango de fechas',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _FechaSelector(
                      label: AppStrings.fechaDesde,
                      fecha: prov.desde,
                      onChanged: (d) =>
                          prov.setFiltroFechas(d, prov.hasta),
                      maxFecha: prov.hasta,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: _FechaSelector(
                      label: AppStrings.fechaHasta,
                      fecha: prov.hasta,
                      onChanged: (d) =>
                          prov.setFiltroFechas(prov.desde, d),
                      minFecha: prov.desde,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text('Formato', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _FormatoTile(
                      formato: 'PDF',
                      icono: Icons.picture_as_pdf_rounded,
                      color: AppColors.critico,
                      seleccionado: _formato == 'PDF',
                      onTap: () => setState(() => _formato = 'PDF'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: _FormatoTile(
                      formato: 'CSV',
                      icono: Icons.table_chart_rounded,
                      color: AppColors.informacion,
                      seleccionado: _formato == 'CSV',
                      onTap: () => setState(() => _formato = 'CSV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: prov.estaExportando
                      ? null
                      : () async {
                          final ok = await prov.exportar(_formato);
                          if (!context.mounted) return;
                          if (ok && prov.rutaExportada != null) {
                            await Share.shareXFiles(
                              [XFile(prov.rutaExportada!, mimeType: 'text/csv')],
                              subject: 'Reporte OryzaFlow',
                            );
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content:
                                  Text(prov.error ?? 'Error al exportar'),
                              backgroundColor: AppColors.critico,
                            ));
                          }
                        },
                  icon: prov.estaExportando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.download_rounded),
                  label: Text(
                      prov.estaExportando ? 'Generando...' : AppStrings.exportar),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FechaSelector extends StatelessWidget {
  final String label;
  final DateTime fecha;
  final ValueChanged<DateTime> onChanged;
  final DateTime? minFecha;
  final DateTime? maxFecha;

  const _FechaSelector({
    required this.label,
    required this.fecha,
    required this.onChanged,
    this.minFecha,
    this.maxFecha,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: minFecha ?? DateTime(2020),
          lastDate: maxFecha ?? DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borde),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textoSecundario)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: AppColors.verde),
                const SizedBox(width: 4),
                Text(DateFormatter.fecha(fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatoTile extends StatelessWidget {
  final String formato;
  final IconData icono;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FormatoTile({
    required this.formato,
    required this.icono,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: seleccionado ? color.withAlpha(15) : null,
          border: Border.all(
              color: seleccionado ? color : AppColors.borde, width: seleccionado ? 2 : 1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Column(
          children: [
            Icon(icono, size: 28, color: color),
            const SizedBox(height: 6),
            Text(formato,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
