import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/node_model.dart';
import '../../models/threshold_model.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class ParametersScreen extends StatelessWidget {
  const ParametersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MonitoringProvider>()..cargarNodos(),
      child: const _ParametersView(),
    );
  }
}

class _ParametersView extends StatefulWidget {
  const _ParametersView();

  @override
  State<_ParametersView> createState() => _ParametersViewState();
}

class _ParametersViewState extends State<_ParametersView> {
  NodeModel? _nodoSel;

  @override
  Widget build(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando && prov.nodos.isEmpty) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.parametros, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.parametros, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarNodos),
          );
        }

        final nodos = prov.nodos;

        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.parametros,
            mostrarBotonAtras: true,
          ),
          body: Column(
            children: [
              if (nodos.isNotEmpty)
                _NodoSelector(
                  nodos: nodos,
                  seleccionado: _nodoSel ?? nodos.first,
                  onChange: (n) {
                    setState(() => _nodoSel = n);
                    prov.cargarConfig(n.id);
                  },
                ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    final nodo = _nodoSel ?? (nodos.isNotEmpty ? nodos.first : null);
                    if (nodo == null) {
                      return const Center(child: Text('Sin nodos disponibles'));
                    }

                    if (prov.estaCargando) {
                      return const ShimmerList();
                    }

                    if (prov.umbrales == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (prov.umbrales == null) prov.cargarConfig(nodo.id);
                      });
                      return const ShimmerList();
                    }

                    return _UmbralForm(
                        nodo: nodo, umbrales: prov.umbrales!, prov: prov);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NodoSelector extends StatelessWidget {
  final List<NodeModel> nodos;
  final NodeModel seleccionado;
  final ValueChanged<NodeModel> onChange;
  const _NodoSelector({
    required this.nodos,
    required this.seleccionado,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.superficie,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM, vertical: 6),
        children: nodos.map((n) {
          final sel = n.id == seleccionado.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(n.nombre),
              selected: sel,
              onSelected: (_) => onChange(n),
              selectedColor: AppColors.verdeFondo,
              checkmarkColor: AppColors.verde,
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: sel
                      ? AppColors.verde
                      : AppColors.textoSecundario),
              side: BorderSide(
                  color: sel ? AppColors.verde : AppColors.borde),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UmbralForm extends StatefulWidget {
  final NodeModel nodo;
  final ThresholdModel umbrales;
  final MonitoringProvider prov;
  const _UmbralForm({
    required this.nodo,
    required this.umbrales,
    required this.prov,
  });

  @override
  State<_UmbralForm> createState() => _UmbralFormState();
}

class _UmbralFormState extends State<_UmbralForm> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _initControllers(widget.umbrales);
  }

  @override
  void didUpdateWidget(_UmbralForm old) {
    super.didUpdateWidget(old);
    if (old.umbrales != widget.umbrales) {
      for (final c in _ctrls.values) {
        c.dispose();
      }
      _initControllers(widget.umbrales);
    }
  }

  void _initControllers(ThresholdModel u) {
    _ctrls = {
      'tempMin': TextEditingController(text: u.temperaturaMin.toString()),
      'tempMax': TextEditingController(text: u.temperaturaMax.toString()),
      'humMin': TextEditingController(text: u.humedadMin.toString()),
      'humMax': TextEditingController(text: u.humedadMax.toString()),
      'flujoMin': TextEditingController(text: u.flujoAireMin.toString()),
      'flujoMax': TextEditingController(text: u.flujoAireMax.toString()),
      'granoMin': TextEditingController(text: u.humedadGranoMin.toString()),
      'granoMax': TextEditingController(text: u.humedadGranoMax.toString()),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final u = ThresholdModel(
      nodoId: widget.nodo.id,
      temperaturaMin: double.tryParse(_ctrls['tempMin']!.text) ?? widget.umbrales.temperaturaMin,
      temperaturaMax: double.tryParse(_ctrls['tempMax']!.text) ?? widget.umbrales.temperaturaMax,
      humedadMin: double.tryParse(_ctrls['humMin']!.text) ?? widget.umbrales.humedadMin,
      humedadMax: double.tryParse(_ctrls['humMax']!.text) ?? widget.umbrales.humedadMax,
      flujoAireMin: double.tryParse(_ctrls['flujoMin']!.text) ?? widget.umbrales.flujoAireMin,
      flujoAireMax: double.tryParse(_ctrls['flujoMax']!.text) ?? widget.umbrales.flujoAireMax,
      humedadGranoMin: double.tryParse(_ctrls['granoMin']!.text) ?? widget.umbrales.humedadGranoMin,
      humedadGranoMax: double.tryParse(_ctrls['granoMax']!.text) ?? widget.umbrales.humedadGranoMax,
    );

    final ok = await widget.prov.guardarUmbrales(u);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Umbrales guardados' : (widget.prov.error ?? 'Error')),
      backgroundColor: ok ? AppColors.verde : AppColors.critico,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        _UmbralSection(
          titulo: AppStrings.temperatura,
          icon: Icons.thermostat_rounded,
          color: AppColors.chartTemperatura,
          unidad: '°C',
          minCtrl: _ctrls['tempMin']!,
          maxCtrl: _ctrls['tempMax']!,
        ),
        _UmbralSection(
          titulo: AppStrings.humedad,
          icon: Icons.water_drop_outlined,
          color: AppColors.chartHumedad,
          unidad: '%',
          minCtrl: _ctrls['humMin']!,
          maxCtrl: _ctrls['humMax']!,
        ),
        _UmbralSection(
          titulo: AppStrings.flujoAire,
          icon: Icons.air_rounded,
          color: AppColors.chartFlujoAire,
          unidad: '%',
          minCtrl: _ctrls['flujoMin']!,
          maxCtrl: _ctrls['flujoMax']!,
        ),
        _UmbralSection(
          titulo: AppStrings.humedadGrano,
          icon: Icons.grass_rounded,
          color: AppColors.chartHumedadGrano,
          unidad: '%',
          minCtrl: _ctrls['granoMin']!,
          maxCtrl: _ctrls['granoMax']!,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.prov.estaProcesando ? null : _guardar,
            child: widget.prov.estaProcesando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Text(AppStrings.guardarCambios),
          ),
        ),
      ],
    );
  }
}

class _UmbralSection extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color color;
  final String unidad;
  final TextEditingController minCtrl;
  final TextEditingController maxCtrl;

  const _UmbralSection({
    required this.titulo,
    required this.icon,
    required this.color,
    required this.unidad,
    required this.minCtrl,
    required this.maxCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(titulo,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: color)),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.umbralMinimo} ($unidad)',
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: TextFormField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.umbralMaximo} ($unidad)',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
