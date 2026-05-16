import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/user_role.dart';
import '../../core/router/route_names.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<UserManagementProvider>(),
      child: const _CreateUserForm(),
    );
  }
}

class _CreateUserForm extends StatefulWidget {
  const _CreateUserForm();

  @override
  State<_CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<_CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfCtrl = TextEditingController();
  UserRole _rol = UserRole.operador;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _passConfCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear(UserManagementProvider prov) async {
    if (!_formKey.currentState!.validate()) return;

    final nuevo = await prov.crearUsuario(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      rol: _rol,
      telefono: _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
    );

    if (!mounted) return;
    if (nuevo != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Usuario creado correctamente'),
        backgroundColor: AppColors.verde,
      ));
      context.go(RouteNames.detalleUsuarioPath(nuevo.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.error ?? 'Error al crear usuario'),
        backgroundColor: AppColors.critico,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (_, prov, __) => Scaffold(
        appBar: OryzaFlowAppBar(
          titulo: AppStrings.crearUsuario,
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
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.nombreCompleto,
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? AppStrings.campoRequerido : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: AppStrings.correoElectronico,
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppStrings.campoRequerido;
                  if (!v.contains('@')) return AppStrings.correoInvalido;
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.telefono,
                  prefixIcon: Icon(Icons.phone_outlined, size: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.contrasena,
                  prefixIcon: Icon(Icons.lock_outline, size: 18),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _passConfCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.confirmarContrasena,
                  prefixIcon: Icon(Icons.lock_clock_outlined, size: 18),
                ),
                validator: (v) => v != _passCtrl.text
                    ? AppStrings.contrasenasNoCoinciden
                    : null,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(AppStrings.rol,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppDimensions.paddingS),
              ...UserRole.values.map((r) => RadioListTile<UserRole>(
                    title: Text(r.displayName),
                    value: r,
                    groupValue: _rol,
                    onChanged: (v) => setState(() => _rol = v ?? _rol),
                    activeColor: AppColors.verde,
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
