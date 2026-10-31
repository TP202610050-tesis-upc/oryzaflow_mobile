import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/esp32_config_model.dart';
import '../../models/node_model.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/sensor_chart_card.dart';

class Esp32ConfigScreen extends StatelessWidget {
  final String? nodoId;
  const Esp32ConfigScreen({super.key, this.nodoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = sl<MonitoringProvider>();
        p.cargarNodos().then((_) {
          final id = nodoId ?? (p.nodos.isNotEmpty ? p.nodos.first.id : null);
          if (id != null) {
            p.cargarConfig(id);
            p.cargarLecturas(id);
          }
        });
        return p;
      },
      child: _Esp32View(nodoId: nodoId),
    );
  }
}

class _Esp32View extends StatefulWidget {
  final String? nodoId;
  const _Esp32View({this.nodoId});

  @override
  State<_Esp32View> createState() => _Esp32ViewState();
}

class _Esp32ViewState extends State<_Esp32View> {
  NodeModel? _nodoSel;

  @override
  Widget build(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando && prov.nodos.isEmpty) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.configEsp32, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }

        final nodos = prov.nodos;
        final nodoActual = _nodoSel ??
            (widget.nodoId != null
                ? nodos.where((n) => n.id == widget.nodoId).firstOrNull
                : null) ??
            (nodos.isNotEmpty ? nodos.first : null);

        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.configEsp32,
            mostrarBotonAtras: true,
          ),
          body: Column(
            children: [
              if (nodos.length > 1)
                _NodoSelectorBar(
                  nodos: nodos,
                  seleccionado: nodoActual,
                  onChange: (n) {
                    setState(() => _nodoSel = n);
                    prov.cargarConfig(n.id);
                    prov.cargarLecturas(n.id);
                  },
                ),
              Expanded(
                child: nodoActual == null
                    ? const Center(child: Text('Sin nodos'))
                    : _NodoDetail(
                        nodo: nodoActual,
                        prov: prov,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NodoSelectorBar extends StatelessWidget {
  final List<NodeModel> nodos;
  final NodeModel? seleccionado;
  final ValueChanged<NodeModel> onChange;
  const _NodoSelectorBar({
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
          final sel = n.id == seleccionado?.id;
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
              side:
                  BorderSide(color: sel ? AppColors.verde : AppColors.borde),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NodoDetail extends StatelessWidget {
  final NodeModel nodo;
  final MonitoringProvider prov;
  const _NodoDetail({required this.nodo, required this.prov});

  @override
  Widget build(BuildContext context) {
    if (prov.estaCargando) return const ShimmerList();
    if (prov.error != null) {
      return ErrorStateWidget(
          mensaje: prov.error, onReintentar: () => prov.cargarConfig(nodo.id));
    }
    if (prov.config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _ConfigForm(nodo: nodo, config: prov.config!, prov: prov);
  }
}

class _ConfigForm extends StatefulWidget {
  final NodeModel nodo;
  final Esp32ConfigModel config;
  final MonitoringProvider prov;
  const _ConfigForm({
    required this.nodo,
    required this.config,
    required this.prov,
  });

  @override
  State<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<_ConfigForm> {
  late TextEditingController _ipCtrl;
  late TextEditingController _puertoCtrl;
  late TextEditingController _intervaloCtrl;
  late bool _wifiActivo;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(text: widget.config.ipAddress);
    _puertoCtrl =
        TextEditingController(text: widget.config.puerto.toString());
    _intervaloCtrl = TextEditingController(
        text: widget.config.intervaloEnvioSegundos.toString());
    _wifiActivo = widget.config.wifiActivo;
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _puertoCtrl.dispose();
    _intervaloCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final config = widget.config.copyWith(
      ipAddress: _ipCtrl.text.trim(),
      puerto: int.tryParse(_puertoCtrl.text) ?? widget.config.puerto,
      intervaloEnvioSegundos:
          int.tryParse(_intervaloCtrl.text) ?? widget.config.intervaloEnvioSegundos,
      wifiActivo: _wifiActivo,
    );
    final ok = await widget.prov.guardarConfig(config);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Configuración guardada' : (widget.prov.error ?? 'Error')),
      backgroundColor: ok ? AppColors.verde : AppColors.critico,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        _SectionTitle('Conectividad'),
        const SizedBox(height: AppDimensions.paddingM),
        TextFormField(
          controller: _ipCtrl,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: AppStrings.ipAddress,
            prefixIcon: Icon(Icons.router_rounded, size: 18),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _puertoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.puerto,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: TextFormField(
                controller: _intervaloCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.intervaloEnvio,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('WiFi activo'),
          subtitle: Text(widget.config.ssid.isNotEmpty
              ? 'SSID: ${widget.config.ssid}'
              : 'Sin red configurada'),
          value: _wifiActivo,
          onChanged: (v) => setState(() => _wifiActivo = v),
          activeThumbColor: AppColors.verde,
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _SectionTitle('Gráficas en Tiempo Real'),
        const SizedBox(height: AppDimensions.paddingM),
        ...SensorTipo.values.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: SensorChartCard(
                tipo: t,
                lecturas: widget.prov.lecturas,
                estaCargando: widget.prov.estaCargandoLecturas,
                valorActual: switch (t) {
                  SensorTipo.temperatura => widget.nodo.temperatura,
                  SensorTipo.humedad => widget.nodo.humedad,
                  SensorTipo.humedadGrano => widget.nodo.humedadGrano,
                },
              ),
            )),
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
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titulo;
  const _SectionTitle(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(titulo, style: Theme.of(context).textTheme.titleSmall);
  }
}
