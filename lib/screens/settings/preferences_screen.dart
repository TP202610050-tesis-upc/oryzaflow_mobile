import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SettingsProvider>()..cargarPreferencias(),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, prov, __) {
        if (prov.estaCargando) {
          return Scaffold(
            appBar: const OryzaFlowAppBar(
                titulo: AppStrings.preferencias, mostrarBotonAtras: true),
            body: const ShimmerList(),
          );
        }

        final prefs = prov.preferencias;
        final unidadTemp = prefs['unidadTemperatura'] as String? ?? 'celsius';
        final unidadPeso = prefs['unidadPeso'] as String? ?? 'kg';
        final notifs = prefs['notificacionesActivas'] as bool? ?? true;
        final sonido = prefs['sonidoActivo'] as bool? ?? true;
        final themeProvider = context.watch<ThemeProvider>();

        return Scaffold(
          appBar: const OryzaFlowAppBar(
            titulo: AppStrings.preferencias,
            mostrarBotonAtras: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            children: [
              _SectionHeader('Apariencia'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Modo Oscuro'),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Tema oscuro activado' : 'Tema claro activado',
                ),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggle(),
              ),
              const Divider(height: 1),
              _SectionHeader('Unidades'),
              _SelectTile(
                icon: Icons.thermostat_rounded,
                titulo: 'Temperatura',
                opciones: const {
                  'Celsius (°C)': 'celsius',
                  'Fahrenheit (°F)': 'fahrenheit',
                },
                valorActual: unidadTemp,
                onChanged: (v) => prov.guardarPreferencia('unidadTemperatura', v),
              ),
              const Divider(height: 1),
              _SelectTile(
                icon: Icons.scale_rounded,
                titulo: 'Peso',
                opciones: const {
                  'Kilogramos (kg)': 'kg',
                  'Toneladas (t)': 'toneladas',
                },
                valorActual: unidadPeso,
                onChanged: (v) => prov.guardarPreferencia('unidadPeso', v),
              ),
              const Divider(height: 1),
              _SectionHeader('Notificaciones'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text(AppStrings.notificaciones),
                subtitle: const Text('Recibir alertas push'),
                value: notifs,
                onChanged: (v) => prov.guardarPreferencia('notificacionesActivas', v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text(AppStrings.sonidoAlertas),
                subtitle: const Text('Sonido al recibir alertas críticas'),
                value: sonido,
                onChanged: (v) => prov.guardarPreferencia('sonidoActivo', v),
              ),
              const Divider(height: 1),
              _SectionHeader('Datos'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Theme.of(context).colorScheme.error),
                ),
                title: Text('Limpiar caché',
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
                subtitle: const Text('Eliminar datos temporales guardados localmente'),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Caché limpiada correctamente')),
                ),
              ),
            ],
          ),
        );
      },
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

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Map<String, String> opciones;
  final String valorActual;
  final ValueChanged<String> onChanged;

  const _SelectTile({
    required this.icon,
    required this.titulo,
    required this.opciones,
    required this.valorActual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primary.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: primary),
      ),
      title: Text(titulo),
      trailing: DropdownButton<String>(
        value: opciones.containsValue(valorActual) ? valorActual : opciones.values.first,
        underline: const SizedBox(),
        items: opciones.entries
            .map((e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(e.key, style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
