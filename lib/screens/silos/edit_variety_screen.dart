import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/variety_model.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class EditVarietyScreen extends StatefulWidget {
  final String? variedadId;
  const EditVarietyScreen({super.key, this.variedadId});

  @override
  State<EditVarietyScreen> createState() => _EditVarietyScreenState();
}

class _EditVarietyScreenState extends State<EditVarietyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _humedadObjetivoCtrl;
  late final TextEditingController _tempMaxCtrl;
  bool _activo = true;
  late SiloProvider _provider;
  VarietyModel? _original;
  bool _inicializado = false;

  bool get _esNuevo => widget.variedadId == null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _humedadObjetivoCtrl = TextEditingController();
    _tempMaxCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _provider = context.read<SiloProvider>();
      if (!_esNuevo) {
        _original = _provider.variedades
            .where((v) => v.id == widget.variedadId)
            .firstOrNull;
        if (_original != null) _llenarFormulario(_original!);
      }
      _inicializado = true;
    }
  }

  void _llenarFormulario(VarietyModel v) {
    _nombreCtrl.text = v.nombre;
    _descCtrl.text = v.descripcion;
    _humedadObjetivoCtrl.text = v.humedadObjetivo.toString();
    _tempMaxCtrl.text = v.temperaturaMaxima.toString();
    _activo = v.activo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _humedadObjetivoCtrl.dispose();
    _tempMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final variedad = VarietyModel(
      id: _original?.id ?? '',
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      humedadObjetivo: double.parse(_humedadObjetivoCtrl.text),
      humedadIngresoMinima: 14.0,
      humedadIngresoMaxima: 28.0,
      temperaturaMaxima: double.parse(_tempMaxCtrl.text),
      tiempoEstimadoHoras: 8,
      activo: _activo,
    );

    final ok =
        await _provider.guardarVariedad(variedad, esNueva: _esNuevo);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Variedad guardada correctamente'),
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
    return ChangeNotifierProvider.value(
      value: sl<SiloProvider>(),
      child: Consumer<SiloProvider>(
        builder: (_, prov, __) {
          _provider = prov;
          return Scaffold(
            appBar: OryzaFlowAppBar(
              titulo: _esNuevo
                  ? AppStrings.nuevaVariedad
                  : AppStrings.editarVariedad,
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
                      labelText: AppStrings.nombreVariedad,
                      prefixIcon: Icon(Icons.grass_rounded, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? AppStrings.campoRequerido : null,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _humedadObjetivoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.humedadObjetivo,
                      prefixIcon: Icon(Icons.water_drop_outlined, size: 18),
                    ),
                    validator: _validarNumero,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _tempMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.temperaturaMaxima,
                      prefixIcon: Icon(Icons.thermostat_rounded, size: 18),
                    ),
                    validator: _validarNumero,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppStrings.descripcion,
                      prefixIcon: Icon(Icons.notes_rounded, size: 18),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Variedad activa'),
                    subtitle: const Text('Disponible para selección en lotes'),
                    value: _activo,
                    onChanged: (v) => setState(() => _activo = v),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validarNumero(String? v) {
    if (v == null || v.isEmpty) return AppStrings.campoRequerido;
    if (double.tryParse(v) == null) return 'Número inválido';
    return null;
  }
}
