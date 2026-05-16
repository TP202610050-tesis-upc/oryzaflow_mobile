import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/enums/user_role.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/role_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuario;
    final rol = user?.rol;

    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.configuracion,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        children: [
          if (user != null) ...[
            _UserTile(user: user),
            const SizedBox(height: AppDimensions.paddingM),
          ],
          _SectionHeader('Apariencia'),
          Consumer<ThemeProvider>(
            builder: (ctx, tp, _) => _SwitchTile(
              icon: tp.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
              titulo: 'Modo Oscuro',
              subtitulo: tp.isDarkMode ? 'Tema oscuro activado' : 'Tema claro activado',
              value: tp.isDarkMode,
              onChanged: (_) => tp.toggle(),
            ),
          ),
          // Sensors section — only Admin and Supervisor may calibrate
          if (rol?.puedeCalibrarSensores == true) ...[
            _SectionHeader('Sensores y Dispositivos'),
            _SettingsTile(
              icon: Icons.tune_rounded,
              titulo: AppStrings.calibrarSensores,
              subtitulo: 'Offsets y calibración por sensor',
              onTap: () => context.push(RouteNames.calibrarSensores),
            ),
          ],
          _SectionHeader('Aplicación'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            titulo: AppStrings.notificaciones,
            subtitulo: 'Alertas push y sonidos',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
            onTap: null,
          ),
          _SectionHeader('Soporte'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            titulo: AppStrings.ayudaFaq,
            subtitulo: 'Preguntas frecuentes',
            onTap: () => context.push(RouteNames.ayudaFaq),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            titulo: 'Acerca de OryzaFlow',
            subtitulo: 'Versión 1.0.0 — Monitoreo IoT de secado de arroz',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppStrings.appNombre,
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 OryzaFlow. Todos los derechos reservados.',
            ),
          ),
          _SettingsTile(
            icon: Icons.article_outlined,
            titulo: 'Licencias',
            subtitulo: 'Licencias de paquetes y bibliotecas de código abierto',
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppStrings.appNombre,
              applicationVersion: '1.0.0',
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: primary.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primary,
            radius: 24,
            child: Text(
              user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(user.email,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
                const SizedBox(height: 4),
                RoleBadge(rol: user.rol),
              ],
            ),
          ),
        ],
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tileColor = Theme.of(context).colorScheme.onSurface;
    final iconColor = primary;
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
          style: TextStyle(fontWeight: FontWeight.w500, color: tileColor)),
      subtitle: Text(subtitulo,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100))
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tileColor = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primary.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: primary),
      ),
      title: Text(titulo,
          style: TextStyle(fontWeight: FontWeight.w500, color: tileColor)),
      subtitle: Text(subtitulo,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: null,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}
