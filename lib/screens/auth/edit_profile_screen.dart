import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/role_badge.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().usuario;
    _nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: user?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.actualizarPerfil(
        userId: auth.usuario!.id,
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuario;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.editarPerfil,
        mostrarBotonAtras: true,
        acciones: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(AppStrings.guardarCambios),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                    child: Text(
                      user.nombre.isNotEmpty
                          ? user.nombre[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RoleBadge(rol: user.rol),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: AppStrings.telefono,
                prefixIcon: Icon(Icons.phone_outlined, size: 18),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            TextFormField(
              initialValue: user.email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: AppStrings.correoElectronico,
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader('Configuración'),
            _SettingsTile(
              icon: Icons.settings_outlined,
              titulo: AppStrings.configuracion,
              subtitulo: 'Calibración, preferencias y más',
              onTap: () => context.go(RouteNames.configuracion),
            ),
            const SizedBox(height: 24),
            _SectionHeader('Sesión'),
            _SettingsTile(
              icon: Icons.lock_reset_rounded,
              titulo: AppStrings.recuperarContrasena,
              subtitulo: 'Solicitar cambio de contraseña por correo',
              onTap: () => context.push(RouteNames.recuperarContrasena),
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              titulo: AppStrings.cerrarSesion,
              subtitulo: 'Salir de la aplicación',
              color: Theme.of(context).colorScheme.error,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content:
                        const Text('¿Estás seguro que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancelar),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Builder(
                          builder: (ctx) => Text(AppStrings.cerrarSesion,
                              style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<AuthProvider>().cerrarSesion();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String titulo;
  const _SectionHeader(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        titulo.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(130)),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = color ?? cs.primary;
    final titleColor = color ?? cs.onSurface;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(titulo,
          style: TextStyle(fontWeight: FontWeight.w500, color: titleColor)),
      subtitle: Text(subtitulo,
          style: TextStyle(
              fontSize: 12, color: cs.onSurface.withAlpha(130))),
      trailing: Icon(Icons.chevron_right_rounded,
          color: cs.onSurface.withAlpha(100)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}
