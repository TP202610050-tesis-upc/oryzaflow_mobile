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
import '../../models/batch_model.dart';
import '../../models/drying_profile_model.dart';
import '../../models/node_model.dart';
import '../../models/silo_model.dart';
import '../../models/variety_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class NewBatchScreen extends StatelessWidget {
  const NewBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<BatchProvider>()..cargarFormularioNuevoLote(),
      child: const _NewBatchForm(),
    );
  }
}

class _NewBatchForm extends StatefulWidget {
  const _NewBatchForm();

  @override
  State<_NewBatchForm> createState() => _NewBatchFormState();
}

class _NewBatchFormState extends State<_NewBatchForm> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _humedadInicialCtrl = TextEditingController();
  final _duenoCtrl = TextEditingController();

  SiloModel? _siloSel;
  VarietyModel? _variedadSel;
  DryingProfileModel? _perfilSel;
  NodeModel? _nodoSel;
  // CA-006-02: el destino comercial es obligatorio; sin él se bloquea "Guardar".
  ProductoDestino? _productoSel;
  bool _faltaProducto = false;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _pesoCtrl.dispose();
    _humedadInicialCtrl.dispose();
    _duenoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear(BatchProvider prov) async {
    final formOk = _formKey.currentState!.validate();
    // CA-006-02: bloquear el registro y mostrar el mensaje del criterio (mismo texto que el 400 del backend).
    setState(() => _faltaProducto = _productoSel == null);
    if (_faltaProducto) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppStrings.destinoComercialObligatorio),
        backgroundColor: AppColors.advertencia,
        duration: Duration(seconds: 4),
      ));
      return;
    }
    if (!formOk) return;
    if (_siloSel == null || _variedadSel == null ||
        _perfilSel == null || _nodoSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona silo, variedad, perfil y nodo'),
        backgroundColor: AppColors.advertencia,
      ));
      return;
    }

    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sesión expirada. Vuelve a iniciar sesión.'),
        backgroundColor: AppColors.critico,
      ));
      return;
    }
    final lote = BatchModel(
      id: '',
      codigo: _codigoCtrl.text.trim(),
      siloId: _siloSel!.id,
      siloNombre: _siloSel!.nombre,
      variedadId: _variedadSel!.id,
      variedadNombre: _variedadSel!.nombre,
      perfilSecadoId: _perfilSel!.id,
      perfilSecadoNombre: _perfilSel!.nombre,
      nodoId: _nodoSel!.id,
      nodoNombre: _nodoSel!.nombre,
      estado: BatchStatus.pendiente,
      pesoKg: double.parse(_pesoCtrl.text),
      humedadInicial: double.parse(_humedadInicialCtrl.text),
      fechaIngreso: DateTime.now(),
      operadorId: usuario.id,
      operadorNombre: usuario.nombre,
      producto: _productoSel,
      duenoCodigo: _duenoCtrl.text.trim().isEmpty ? null : _duenoCtrl.text.trim(),
    );

    final nuevo = await prov.crearLote(lote);
    if (!mounted) return;
    if (nuevo != null) {
      context.go(RouteNames.detalleLotePath(nuevo.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.error ?? 'Error al crear lote'),
        backgroundColor: AppColors.critico,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.nuevoLote, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }
        if (prov.error != null && prov.silos.isEmpty) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.nuevoLote, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error,
                onReintentar: prov.cargarFormularioNuevoLote),
          );
        }

        return Scaffold(
          appBar: OryzaFlowAppBar(
            titulo: AppStrings.nuevoLote,
            mostrarBotonAtras: true,
            acciones: [
              TextButton(
                onPressed: prov.estaProcesando ? null : () => _crear(prov),
                child: prov.estaProcesando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(AppStrings.crear),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                TextFormField(
                  controller: _codigoCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.codigoLote,
                    prefixIcon: Icon(Icons.tag_rounded, size: 18),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? AppStrings.campoRequerido
                      : null,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _DropdownField<VarietyModel>(
                  label: AppStrings.variedadArroz,
                  items: prov.variedades,
                  value: _variedadSel,
                  itemLabel: (v) => v.nombre,
                  onChanged: (v) => setState(() => _variedadSel = v),
                  icon: Icons.grass_rounded,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _ProductoSelector(
                  value: _productoSel,
                  error: _faltaProducto,
                  onChanged: (p) => setState(() {
                    _productoSel = p;
                    _faltaProducto = false;
                  }),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _DropdownField<SiloModel>(
                  label: AppStrings.siloAsignado,
                  items: prov.silos
                      .where((s) => s.estado == SiloStatus.disponible)
                      .toList(),
                  value: _siloSel,
                  itemLabel: (s) =>
                      '${s.nombre} (${s.capacidadKg.toStringAsFixed(0)} kg)',
                  onChanged: (s) => setState(() => _siloSel = s),
                  icon: Icons.warehouse_rounded,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _DropdownField<NodeModel>(
                  label: AppStrings.nodoAsignado,
                  items: prov.nodos,
                  value: _nodoSel,
                  itemLabel: (n) => '${n.nombre} — ${n.ubicacion}',
                  onChanged: (n) => setState(() => _nodoSel = n),
                  icon: Icons.sensors_rounded,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _DropdownField<DryingProfileModel>(
                  label: AppStrings.perfilSecado,
                  items: prov.perfiles,
                  value: _perfilSel,
                  itemLabel: (p) => p.nombre,
                  onChanged: (p) => setState(() => _perfilSel = p),
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pesoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: AppStrings.pesoKg),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.campoRequerido;
                          }
                          if (double.tryParse(v) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: TextFormField(
                        controller: _humedadInicialCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: AppStrings.humedadInicial),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.campoRequerido;
                          }
                          if (double.tryParse(v) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                TextFormField(
                  controller: _duenoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dueño del grano (código, opcional)',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                  ),
                ),
                if (_perfilSel != null) ...[
                  const SizedBox(height: AppDimensions.paddingL),
                  _PerfilResumen(perfil: _perfilSel!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CA-006-02: selector obligatorio del destino comercial (fija la humedad meta).
class _ProductoSelector extends StatelessWidget {
  final ProductoDestino? value;
  final bool error;
  final ValueChanged<ProductoDestino> onChanged;
  const _ProductoSelector({required this.value, required this.error, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final borde = error ? AppColors.critico : AppColors.borde;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: borde, width: error ? 1.5 : 1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_rounded, size: 18, color: AppColors.textoSecundario),
              const SizedBox(width: 8),
              Text('${AppStrings.destinoComercial} *',
                  style: TextStyle(
                      fontSize: 13,
                      color: error ? AppColors.critico : AppColors.textoSecundario)),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<ProductoDestino>(
            segments: ProductoDestino.values
                .map((p) => ButtonSegment(value: p, label: Text(p.displayName)))
                .toList(),
            selected: value == null ? const {} : {value!},
            emptySelectionAllowed: true,
            onSelectionChanged: (s) {
              if (s.isNotEmpty) onChanged(s.first);
            },
          ),
          const SizedBox(height: 6),
          Text(
            error
                ? AppStrings.destinoComercialObligatorio
                : (value?.descripcion ?? 'Fija la humedad meta del lote'),
            style: TextStyle(
                fontSize: 12,
                color: error ? AppColors.critico : AppColors.textoSecundario),
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final IconData icon;

  const _DropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
      ),
      items: items
          .map((i) =>
              DropdownMenuItem<T>(value: i, child: Text(itemLabel(i))))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? AppStrings.campoRequerido : null,
      isExpanded: true,
    );
  }
}

class _PerfilResumen extends StatelessWidget {
  final DryingProfileModel perfil;
  const _PerfilResumen({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.verdeFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.verde.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perfil: ${perfil.nombre}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.verde)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _KV('Temp. obj.', '${perfil.temperaturaObjetivo}°C'),
              _KV('H. obj.', '${perfil.humedadObjetivo}%'),
              _KV('Duración est.',
                  '${(perfil.duracionEstimadaMinutos / 60).toStringAsFixed(0)}h'),
            ],
          ),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 12, color: AppColors.textoSecundario),
        children: [
          TextSpan(text: '$k: '),
          TextSpan(
              text: v,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoPrimario)),
        ],
      ),
    );
  }
}
