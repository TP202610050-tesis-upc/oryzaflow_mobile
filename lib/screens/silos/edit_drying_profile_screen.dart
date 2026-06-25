import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../models/drying_profile_model.dart';
import '../../providers/silo_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class EditDryingProfileScreen extends StatefulWidget {
  final DryingProfileModel? perfil;
  const EditDryingProfileScreen({super.key, this.perfil});

  @override
  State<EditDryingProfileScreen> createState() =>
      _EditDryingProfileScreenState();
}

class _EditDryingProfileScreenState extends State<EditDryingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _humedadGranoObjetivoCtrl;
  late final TextEditingController _temperaturaObjetivoCtrl;
  late final TextEditingController _humedadObjetivoCtrl;
  late final TextEditingController _duracionCtrl;
  late SiloProvider _provider;

  bool get _esNuevo => widget.perfil == null;

  @override
  void initState() {
    super.initState();
    final p = widget.perfil;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _descCtrl = TextEditingController(text: p?.descripcion ?? '');
    _humedadGranoObjetivoCtrl = TextEditingController(
        text: p != null ? p.humedadGranoObjetivo.toString() : '');
    _temperaturaObjetivoCtrl = TextEditingController(
        text: p != null ? p.temperaturaObjetivo.toString() : '');
    _humedadObjetivoCtrl = TextEditingController(
        text: p != null ? p.humedadObjetivo.toString() : '');
    _duracionCtrl = TextEditingController(
        text: p != null ? p.duracionEstimadaMinutos.toString() : '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _humedadGranoObjetivoCtrl.dispose();
    _temperaturaObjetivoCtrl.dispose();
    _humedadObjetivoCtrl.dispose();
    _duracionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final perfil = DryingProfileModel(
      id: widget.perfil?.id ?? '',
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      humedadGranoObjetivo: double.parse(_humedadGranoObjetivoCtrl.text),
      temperaturaObjetivo: double.parse(_temperaturaObjetivoCtrl.text),
      humedadObjetivo: double.parse(_humedadObjetivoCtrl.text),
      duracionEstimadaMinutos: int.parse(_duracionCtrl.text),
      creadoEn: widget.perfil?.creadoEn ?? DateTime.now(),
      creadoPorId: widget.perfil?.creadoPorId ?? '',
    );

    final ok = await _provider.guardarPerfil(perfil, esNuevo: _esNuevo);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Perfil de secado guardado correctamente'),
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
              titulo: _esNuevo
                  ? AppStrings.nuevoPerfilSecado
                  : AppStrings.editarPerfilSecado,
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
                      labelText: AppStrings.nombrePerfil,
                      prefixIcon: Icon(Icons.tune_rounded, size: 18),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? AppStrings.campoRequerido : null,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _humedadGranoObjetivoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.humedadGranoObjetivo,
                      helperText: 'M_target — humedad comercial a alcanzar',
                      prefixIcon: Icon(Icons.grass_rounded, size: 18),
                    ),
                    validator: _validarNumero,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextFormField(
                    controller: _temperaturaObjetivoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.temperaturaObjetivo,
                      prefixIcon: Icon(Icons.thermostat_rounded, size: 18),
                    ),
                    validator: _validarNumero,
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
                    controller: _duracionCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.duracionEstimada,
                      prefixIcon: Icon(Icons.schedule_rounded, size: 18),
                    ),
                    validator: _validarEntero,
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

  String? _validarEntero(String? v) {
    if (v == null || v.isEmpty) return AppStrings.campoRequerido;
    if (int.tryParse(v) == null) return 'Ingresa un entero válido';
    return null;
  }
}
