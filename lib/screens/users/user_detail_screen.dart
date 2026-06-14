import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/role_badge.dart';

class UserDetailScreen extends StatelessWidget {
  final String usuarioId;
  const UserDetailScreen({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          sl<UserManagementProvider>()..cargarUsuario(usuarioId),
      child: _UserDetailView(usuarioId: usuarioId),
    );
  }
}

class _UserDetailView extends StatelessWidget {
  final String usuarioId;
  const _UserDetailView({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().usuario;

    return Consumer<UserManagementProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando && prov.usuarioSeleccionado == null) {
          return const Scaffold(
            appBar: OryzaFlowAppBar(
                titulo: AppStrings.detalleUsuario, mostrarBotonAtras: true),
            body: ShimmerList(),
          );
        }
        if (prov.error != null && prov.usuarioSeleccionado == null) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.detalleUsuario, mostrarBotonAtras: true),
            body: ErrorStateWidget(
                mensaje: prov.error,
                onReintentar: () => prov.cargarUsuario(usuarioId)),
          );
        }
        final user = prov.usuarioSeleccionado;
        if (user == null) {
          return const Scaffold(
              appBar: OryzaFlowAppBar(
                  titulo: AppStrings.detalleUsuario, mostrarBotonAtras: true),
              body: EmptyStateWidget(mensaje: 'Usuario no encontrado'));
        }

        final esYoMismo = user.id == currentUser?.id;
        final puedeAdministrar =
            currentUser?.rol.puedeVerUsuarios == true && !esYoMismo;

        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.detalleUsuario,
            mostrarBotonAtras: true,
          ),
          body: _UserDetailForm(
            user: user,
            prov: prov,
            puedeAdministrar: puedeAdministrar,
          ),
        );
      },
    );
  }
}

class _UserDetailForm extends StatefulWidget {
  final UserModel user;
  final UserManagementProvider prov;
  final bool puedeAdministrar;

  const _UserDetailForm({
    required this.user,
    required this.prov,
    required this.puedeAdministrar,
  });

  @override
  State<_UserDetailForm> createState() => _UserDetailFormState();
}

class _UserDetailFormState extends State<_UserDetailForm> {
  late UserRole _rolLocal;
  late bool _activoLocal;

  @override
  void initState() {
    super.initState();
    _rolLocal = widget.user.rol;
    _activoLocal = widget.user.activo;
  }

  @override
  void didUpdateWidget(_UserDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      _rolLocal = widget.user.rol;
      _activoLocal = widget.user.activo;
    }
  }

  Future<void> _guardar() async {
    final prov = widget.prov;
    final user = widget.user;
    var ok = true;
    if (_rolLocal != user.rol) ok = await prov.cambiarRol(user.id, _rolLocal);
    if (ok && _activoLocal != user.activo) {
      ok = await prov.cambiarEstado(user.id, _activoLocal);
    }
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Cambios guardados'
            : (prov.error ?? 'No se pudieron guardar los cambios')),
        backgroundColor: ok ? cs.primary : cs.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        _AvatarSection(user: user),
        const SizedBox(height: AppDimensions.paddingM),
        _InfoSection(user: user),
        if (widget.puedeAdministrar) ...[
          const SizedBox(height: AppDimensions.paddingM),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.rol,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppDimensions.paddingS),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserRole.values.map((r) => ChoiceChip(
                      label: Text(r.displayName),
                      selected: _rolLocal == r,
                      onSelected: widget.prov.estaProcesando
                          ? null
                          : (_) => setState(() => _rolLocal = r),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado de la Cuenta',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppDimensions.paddingS),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_activoLocal ? 'Cuenta activa' : 'Cuenta inactiva'),
                    subtitle: Text(
                      _activoLocal
                          ? 'El usuario puede iniciar sesión'
                          : 'El usuario no puede acceder al sistema',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _activoLocal,
                    onChanged: widget.prov.estaProcesando
                        ? null
                        : (v) => setState(() => _activoLocal = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.prov.estaProcesando ? null : _guardar,
              child: widget.prov.estaProcesando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar cambios'),
            ),
          ),
        ],
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final UserModel user;
  const _AvatarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primary.withAlpha(30),
            child: Text(
              user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: cs.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(user.nombre,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          RoleBadge(rol: user.rol),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: user.activo
                  ? cs.primary.withAlpha(30)
                  : cs.outline.withAlpha(60),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              user.activo ? AppStrings.activo : AppStrings.inactivo,
              style: TextStyle(
                  fontSize: 11,
                  color: user.activo
                      ? cs.primary
                      : cs.onSurface.withAlpha(130)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserModel user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppDimensions.paddingM),
            _InfoRow(Icons.email_outlined, 'Email', user.email),
            if (user.telefono != null && user.telefono!.isNotEmpty)
              _InfoRow(Icons.phone_outlined, 'Teléfono', user.telefono!),
            _InfoRow(Icons.calendar_today_rounded, 'Registrado',
                DateFormatter.fecha(user.creadoEn)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurface.withAlpha(130)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withAlpha(130))),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
