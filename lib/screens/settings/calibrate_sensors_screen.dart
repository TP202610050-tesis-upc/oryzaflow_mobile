import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/node_model.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class CalibrateSensorsScreen extends StatelessWidget {
  const CalibrateSensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rol = context.read<AuthProvider>().usuario?.rol;
    if (rol?.puedeCalibrarSensores != true) {
      return Scaffold(
        appBar: const OryzaFlowAppBar(
            titulo: AppStrings.calibrarSensores, mostrarBotonAtras: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(80)),
                const SizedBox(height: 16),
                Text('Acceso restringido',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Esta función requiere permisos de Supervisor o Administrador.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => sl<MonitoringProvider>()..cargarNodos(),
      child: const _CalibrateView(),
    );
  }
}

class _CalibrateView extends StatefulWidget {
  const _CalibrateView();

  @override
  State<_CalibrateView> createState() => _CalibrateViewState();
}

class _CalibrateViewState extends State<_CalibrateView> {
  NodeModel? _nodoSel;

  @override
  Widget build(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando && prov.nodos.isEmpty) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.calibrarSensores, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.calibrarSensores, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarNodos),
          );
        }

        final nodos = prov.nodos;
        final nodo = _nodoSel ?? (nodos.isNotEmpty ? nodos.first : null);

        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.calibrarSensores,
            mostrarBotonAtras: true,
          ),
          body: Column(
            children: [
              if (nodos.length > 1)
                _NodoSelector(
                  nodos: nodos,
                  seleccionado: nodo,
                  onChange: (n) {
                    setState(() => _nodoSel = n);
                    prov.cargarConfig(n.id);
                  },
                ),
              Expanded(
                child: nodo == null
                    ? const Center(child: Text('Sin nodos disponibles'))
                    : _OffsetForm(nodo: nodo, prov: prov),
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
  final NodeModel? seleccionado;
  final ValueChanged<NodeModel> onChange;
  const _NodoSelector(
      {required this.nodos, required this.seleccionado, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      color: cs.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM, vertical: 6),
        children: nodos.map((n) {
          final sel = n.id == seleccionado?.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(n.nombre),
              selected: sel,
              onSelected: (_) => onChange(n),
              selectedColor: cs.primary.withAlpha(30),
              checkmarkColor: cs.primary,
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: sel ? cs.primary : cs.onSurface.withAlpha(130)),
              side: BorderSide(color: sel ? cs.primary : cs.outline),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OffsetForm extends StatefulWidget {
  final NodeModel nodo;
  final MonitoringProvider prov;
  const _OffsetForm({required this.nodo, required this.prov});

  @override
  State<_OffsetForm> createState() => _OffsetFormState();
}

class _OffsetFormState extends State<_OffsetForm> {
  late TextEditingController _offsetTempCtrl;
  late TextEditingController _offsetHumCtrl;
  late TextEditingController _offsetFlujoCtrl;
  late TextEditingController _offsetGranoCtrl;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _offsetTempCtrl = TextEditingController(text: '0.0');
    _offsetHumCtrl = TextEditingController(text: '0.0');
    _offsetFlujoCtrl = TextEditingController(text: '0.0');
    _offsetGranoCtrl = TextEditingController(text: '0.0');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.prov.cargarConfig(widget.nodo.id);
    });
  }

  @override
  void didUpdateWidget(_OffsetForm old) {
    super.didUpdateWidget(old);
    if (!_inicializado && widget.prov.config != null) {
      final c = widget.prov.config!;
      _offsetTempCtrl.text = c.offsetTemperatura.toString();
      _offsetHumCtrl.text = c.offsetHumedad.toString();
      _offsetFlujoCtrl.text = c.offsetFlujoAire.toString();
      _offsetGranoCtrl.text = c.offsetHumedadGrano.toString();
      _inicializado = true;
    }
  }

  @override
  void dispose() {
    _offsetTempCtrl.dispose();
    _offsetHumCtrl.dispose();
    _offsetFlujoCtrl.dispose();
    _offsetGranoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final config = widget.prov.config;
    if (config == null) return;

    final updated = config.copyWith(
      offsetTemperatura: double.tryParse(_offsetTempCtrl.text) ?? config.offsetTemperatura,
      offsetHumedad: double.tryParse(_offsetHumCtrl.text) ?? config.offsetHumedad,
      offsetFlujoAire: double.tryParse(_offsetFlujoCtrl.text) ?? config.offsetFlujoAire,
      offsetHumedadGrano: double.tryParse(_offsetGranoCtrl.text) ?? config.offsetHumedadGrano,
    );
    final ok = await widget.prov.guardarConfig(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Calibración guardada' : (widget.prov.error ?? 'Error')),
      backgroundColor: ok ? AppColors.verde : AppColors.critico,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prov.estaCargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        Text(
          'Offset = valor que se suma/resta a la lectura del sensor para ajustar la calibración.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textoSecundario),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _OffsetTile(
          titulo: AppStrings.temperatura,
          icon: Icons.thermostat_rounded,
          color: AppColors.chartTemperatura,
          unidad: '°C',
          ctrl: _offsetTempCtrl,
        ),
        _OffsetTile(
          titulo: AppStrings.humedad,
          icon: Icons.water_drop_outlined,
          color: AppColors.chartHumedad,
          unidad: '%',
          ctrl: _offsetHumCtrl,
        ),
        _OffsetTile(
          titulo: AppStrings.flujoAire,
          icon: Icons.air_rounded,
          color: AppColors.chartFlujoAire,
          unidad: '%',
          ctrl: _offsetFlujoCtrl,
        ),
        _OffsetTile(
          titulo: AppStrings.humedadGrano,
          icon: Icons.grass_rounded,
          color: AppColors.chartHumedadGrano,
          unidad: '%',
          ctrl: _offsetGranoCtrl,
        ),
        const SizedBox(height: AppDimensions.paddingM),
        SizedBox(
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

class _OffsetTile extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color color;
  final String unidad;
  final TextEditingController ctrl;

  const _OffsetTile({
    required this.titulo,
    required this.icon,
    required this.color,
    required this.unidad,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(titulo,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                suffixText: unidad,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
