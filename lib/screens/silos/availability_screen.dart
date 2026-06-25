import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/silo_model.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SiloProvider>()..cargarDisponibilidad(),
      child: const _AvailabilityView(),
    );
  }
}

class _AvailabilityView extends StatelessWidget {
  const _AvailabilityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OryzaFlowAppBar(
        titulo: AppStrings.disponibilidad,
        mostrarBotonAtras: true,
      ),
      body: Consumer<SiloProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error,
                onReintentar: prov.cargarDisponibilidad);
          }

          final dias = prov.disponibilidad.keys.toList()..sort();

          if (dias.isEmpty) {
            return const Center(child: Text('Sin datos de disponibilidad'));
          }

          return Column(
            children: [
              _Leyenda(),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Próximos 14 días',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppDimensions.paddingM),
                      ...dias.map((dia) => _DiaRow(
                            dia: dia,
                            silos: prov.disponibilidad[dia] ?? [],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (AppColors.verde, 'Disponible'),
      (AppColors.advertencia, 'Ocupado'),
      (AppColors.textoSecundario, 'Mantenimiento'),
    ];
    return Container(
      color: AppColors.superficie,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM, vertical: 8),
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: item.$1, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(item.$2,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textoSecundario)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DiaRow extends StatelessWidget {
  final DateTime dia;
  final List<SiloModel> silos;
  const _DiaRow({required this.dia, required this.silos});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final esHoy = dia.year == hoy.year &&
        dia.month == hoy.month &&
        dia.day == hoy.day;

    final diasSemana = [
      'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'
    ];
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${diasSemana[dia.weekday - 1]} ${dia.day} ${meses[dia.month - 1]}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        esHoy ? FontWeight.w700 : FontWeight.w400,
                    color: esHoy
                        ? AppColors.verde
                        : AppColors.textoPrimario,
                  ),
                ),
                if (esHoy)
                  const Text('Hoy',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.verde)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: silos.map((s) => _SiloTag(silo: s)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiloTag extends StatelessWidget {
  final SiloModel silo;
  const _SiloTag({required this.silo});

  Color get _color => switch (silo.estado) {
        SiloStatus.disponible => AppColors.verde,
        SiloStatus.ocupado => AppColors.advertencia,
        SiloStatus.mantenimiento => AppColors.textoSecundario,
        SiloStatus.deBaja => AppColors.textoSecundario,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: _color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(silo.nombre,
              style: TextStyle(fontSize: 11, color: _color)),
        ],
      ),
    );
  }
}
