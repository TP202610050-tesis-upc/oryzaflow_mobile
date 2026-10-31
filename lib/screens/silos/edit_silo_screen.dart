import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/silo_model.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class EditSiloScreen extends StatefulWidget {
  final SiloModel? silo;
  const EditSiloScreen({super.key, this.silo});

  @override
  State<EditSiloScreen> createState() => _EditSiloScreenState();
}

class _EditSiloScreenState extends State<EditSiloScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _ubicacionCtrl;
  late final TextEditingController _capacidadCtrl;
  late final TextEditingController _serialCtrl;
  SiloStatus _estado = SiloStatus.disponible;
  late SiloProvider _provider;

  bool get _esNuevo => widget.silo == null;

  @override
  void initState() {
    super.initState();
    final s = widget.silo;
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _ubicacionCtrl = TextEditingController(text: s?.ubicacion ?? '');
    _capacidadCtrl = TextEditingController(
        text: s != null ? s.capacidadKg.toString() : '');
    _serialCtrl = TextEditingController(text: s?.serialEsp32 ?? '');
    if (s != null) _estado = s.estado;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ubicacionCtrl.dispose();
    _capacidadCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final serial = _serialCtrl.text.trim();
    final silo = SiloModel(
      id: widget.silo?.id ?? '',
      nombre: _nombreCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      capacidadKg: double.parse(_capacidadCtrl.text),
      superficie: widget.silo?.superficie ?? 0,
      estado: _estado,
      loteActivoId: widget.silo?.loteActivoId,
      ocupacionActualKg: widget.silo?.ocupacionActualKg,
      serialEsp32: serial.isEmpty ? null : serial,
    );

    final ok = await _provider.guardarSilo(silo, esNuevo: _esNuevo);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Silo guardado correctamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_provider.error ?? 'Error al guardar'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SiloProvider>(),
      child: Consumer<SiloProvider>(
        builder: (_, prov, __) {
          _provider = prov;
          return Scaffold(
            appBar: OryzaFlowAppBar(
              titulo: _esNuevo ? AppStrings.nuevoSilo : AppStrings.editarSilo,
              mostrarBotonAtras: true,
              acciones: [
                TextButton(
                  onPressed: prov.estaGuardando ? null : _guardar,
                  child: prov.estaGuardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text(AppStrings.guardar),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.nombreSilo,
                      prefixIcon: Icon(Icons.warehouse_rounded, size: 18),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? AppStrings.campoRequerido
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _ubicacionCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.ubicacion,
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? AppStrings.campoRequerido
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _capacidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.capacidadToneladas,
                      prefixIcon: Icon(Icons.scale_rounded, size: 18),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.campoRequerido;
                      if (double.tryParse(v) == null) return 'Número inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _serialCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Serial ESP32',
                      prefixIcon: Icon(Icons.memory_rounded, size: 18),
                      hintText: 'Ej: ESP32-001-ABC',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  DropdownButtonFormField<SiloStatus>(
                    initialValue: _estado,
                    decoration: const InputDecoration(
                      labelText: AppStrings.estadoSilo,
                      prefixIcon: Icon(Icons.toggle_on_outlined, size: 18),
                    ),
                    items: SiloStatus.values
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.displayName)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _estado = v);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
