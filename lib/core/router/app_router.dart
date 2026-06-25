import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../models/drying_profile_model.dart';
import '../../models/silo_model.dart';
import '../../models/user_model.dart';
import '../../models/variety_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/edit_profile_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/recover_password_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/batches/batch_detail_screen.dart';
import '../../screens/batches/batches_list_screen.dart';
import '../../screens/batches/new_batch_screen.dart';
import '../../screens/dashboard/alerts_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/monitoring/esp32_config_screen.dart';
import '../../screens/monitoring/monitoring_screen.dart';
import '../../screens/reports/drying_charts_screen.dart';
import '../../screens/reports/drying_history_screen.dart';
import '../../screens/reports/export_report_screen.dart';
import '../../screens/reports/kpi_screen.dart';
import '../../screens/settings/calibrate_sensors_screen.dart';
import '../../screens/settings/help_faq_screen.dart';
import '../../screens/settings/preferences_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/silos/availability_screen.dart';
import '../../screens/silos/drying_profiles_screen.dart';
import '../../screens/silos/edit_drying_profile_screen.dart';
import '../../screens/silos/edit_silo_screen.dart';
import '../../screens/silos/edit_variety_screen.dart';
import '../../screens/silos/silos_screen.dart';
import '../../screens/silos/varieties_screen.dart';
import '../../screens/users/create_user_screen.dart';
import '../../screens/users/user_detail_screen.dart';
import '../../screens/users/users_list_screen.dart';
import '../constants/app_strings.dart';
import 'route_names.dart';

class AppRouter {
  final AuthProvider _authProvider;
  late final GoRouter _router;

  AppRouter(this._authProvider) {
    _router = GoRouter(
      initialLocation: RouteNames.splash,
      refreshListenable: _authProvider,
      redirect: _guard,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.recuperarContrasena,
          builder: (_, __) => const RecoverPasswordScreen(),
        ),
        GoRoute(
          path: RouteNames.editarPerfil,
          builder: (_, __) => const EditProfileScreen(),
        ),
        ShellRoute(
          builder: (_, state, child) => _AppShell(location: state.matchedLocation, child: child),
          routes: [
            GoRoute(path: RouteNames.dashboard, builder: (_, __) => const DashboardScreen()),
            GoRoute(path: RouteNames.alertas, builder: (_, __) => const AlertsScreen()),
            // Silos
            GoRoute(
              path: RouteNames.silos,
              builder: (_, __) => const SilosScreen(),
              routes: [
                GoRoute(path: 'editar', builder: (_, state) => EditSiloScreen(silo: state.extra as SiloModel?)),
                GoRoute(
                  path: 'variedades',
                  builder: (_, __) => const VarietiesScreen(),
                  routes: [
                    GoRoute(path: 'editar', builder: (_, state) => EditVarietyScreen(variedad: state.extra as VarietyModel?)),
                  ],
                ),
                GoRoute(
                  path: 'perfiles',
                  builder: (_, __) => const DryingProfilesScreen(),
                  routes: [
                    GoRoute(path: 'editar', builder: (_, state) => EditDryingProfileScreen(perfil: state.extra as DryingProfileModel?)),
                  ],
                ),
                GoRoute(path: 'disponibilidad', builder: (_, __) => const AvailabilityScreen()),
              ],
            ),
            // Lotes
            GoRoute(
              path: RouteNames.lotes,
              builder: (_, __) => const BatchesListScreen(),
              routes: [
                GoRoute(path: 'nuevo', builder: (_, __) => const NewBatchScreen()),
                GoRoute(path: ':loteId', builder: (_, state) => BatchDetailScreen(loteId: state.pathParameters['loteId']!)),
              ],
            ),
            // Monitoreo
            GoRoute(
              path: RouteNames.monitoreo,
              builder: (_, __) => const MonitoringScreen(),
              routes: [
                GoRoute(path: 'esp32', builder: (_, state) => Esp32ConfigScreen(nodoId: state.uri.queryParameters['nodo'])),
              ],
            ),
            // Reportes
            GoRoute(
              path: RouteNames.reportes,
              builder: (_, __) => const DryingHistoryScreen(),
              routes: [
                GoRoute(path: 'graficas', builder: (_, state) => DryingChartsScreen(loteId: state.uri.queryParameters['lote'])),
                GoRoute(path: 'kpis', builder: (_, __) => const KpiScreen()),
                GoRoute(path: 'exportar', builder: (_, __) => const ExportReportScreen()),
              ],
            ),
            // Usuarios (Admin only — route exists but drawer guards visibility)
            GoRoute(
              path: RouteNames.usuarios,
              builder: (_, __) => const UsersListScreen(),
              routes: [
                GoRoute(path: 'nuevo', builder: (_, __) => const CreateUserScreen()),
                GoRoute(path: ':usuarioId', builder: (_, state) => UserDetailScreen(usuarioId: state.pathParameters['usuarioId']!)),
              ],
            ),
            // Configuración
            GoRoute(
              path: RouteNames.configuracion,
              builder: (_, __) => const SettingsScreen(),
              routes: [
                GoRoute(path: 'calibrar', builder: (_, __) => const CalibrateSensorsScreen()),
                GoRoute(path: 'ayuda', builder: (_, __) => const HelpFaqScreen()),
                GoRoute(path: 'preferencias', builder: (_, __) => const PreferencesScreen()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  GoRouter get router => _router;

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuth = _authProvider.estaAutenticado;
    final isInit = _authProvider.estado == AuthEstado.inicial ||
        _authProvider.estado == AuthEstado.cargando;
    final loc = state.matchedLocation;

    if (isInit) return null;

    if (loc == RouteNames.splash) {
      return isAuth ? RouteNames.dashboard : RouteNames.login;
    }

    if (!isAuth && loc != RouteNames.login && loc != RouteNames.recuperarContrasena) {
      return RouteNames.login;
    }
    if (isAuth && loc == RouteNames.login) return RouteNames.dashboard;
    return null;
  }
}

// ─── Shell Scaffold ────────────────────────────────────────────────────────────

class _AppShell extends StatefulWidget {
  final Widget child;
  final String location;

  const _AppShell({required this.child, required this.location});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  static List<String> _tabsForRole(UserRole? rol) {
    if (rol == UserRole.admin) {
      return [RouteNames.dashboard, RouteNames.usuarios, RouteNames.silos];
    }
    return [RouteNames.dashboard, RouteNames.monitoreo, RouteNames.lotes];
  }

  int _tabIndexFor(List<String> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (widget.location.startsWith(tabs[i])) return i;
    }
    return 0;
  }

  List<NavigationDestination> _destinationsForRole(UserRole? rol) {
    if (rol == UserRole.admin) {
      return const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), selectedIcon: Icon(Icons.manage_accounts), label: 'Usuarios'),
        NavigationDestination(icon: Icon(Icons.warehouse_outlined), selectedIcon: Icon(Icons.warehouse), label: 'Infraestructura'),
      ];
    }
    return const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Inicio'),
      NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'Monitoreo'),
      NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Lotes'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthProvider>().usuario?.rol;
    final tabs = _tabsForRole(rol);
    final destinations = _destinationsForRole(rol);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: NavigationBar(
          selectedIndex: _tabIndexFor(tabs),
          onDestinationSelected: (i) => context.go(tabs[i]),
          destinations: destinations,
        ),
      ),
      drawer: _AppDrawer(currentLocation: widget.location),
    );
  }
}

// ─── App Drawer ────────────────────────────────────────────────────────────────

const _kDrawerBg = Color(0xFF043A3A);
const _kDrawerDivider = Color(0xFF0F4F4F);
const _kDrawerItemText = Color(0xFFADC8C8);
const _kDrawerSelectedText = Color(0xFF81C784);
const _kDrawerSelectedBar = Color(0xFF66BB6A);

class _AppDrawer extends StatelessWidget {
  final String currentLocation;

  const _AppDrawer({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuario;
    final rol = user?.rol;

    return Drawer(
      backgroundColor: _kDrawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerUserHeader(user: user),
            const Divider(height: 1, thickness: 1, color: _kDrawerDivider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: AppStrings.navInicio,
                    route: RouteNames.dashboard,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.navAlertas,
                    route: RouteNames.alertas,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.warehouse_outlined,
                    label: AppStrings.navSilos,
                    route: RouteNames.silos,
                    current: currentLocation,
                    selectedIf: (loc) =>
                        loc.startsWith(RouteNames.silos) &&
                        !loc.startsWith(RouteNames.variedades) &&
                        !loc.startsWith(RouteNames.perfilesSecado),
                  ),
                  _DrawerItem(
                    icon: Icons.grass_outlined,
                    label: AppStrings.variedades,
                    route: RouteNames.variedades,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.tune_outlined,
                    label: AppStrings.perfilesSecado,
                    route: RouteNames.perfilesSecado,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: AppStrings.navLotes,
                    route: RouteNames.lotes,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.sensors_outlined,
                    label: AppStrings.navMonitoreo,
                    route: RouteNames.monitoreo,
                    current: currentLocation,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    label: AppStrings.navReportes,
                    route: RouteNames.reportes,
                    current: currentLocation,
                  ),
                  if (rol?.puedeVerUsuarios == true)
                    _DrawerItem(
                      icon: Icons.manage_accounts_outlined,
                      label: AppStrings.navUsuarios,
                      route: RouteNames.usuarios,
                      current: currentLocation,
                    ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: AppStrings.navConfiguracion,
                    route: RouteNames.configuracion,
                    current: currentLocation,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: _kDrawerDivider),
            _DrawerItem(
              icon: Icons.person_outlined,
              label: AppStrings.navPerfil,
              route: RouteNames.editarPerfil,
              current: currentLocation,
            ),
            _DrawerLogoutButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer User Header ────────────────────────────────────────────────────────

class _DrawerUserHeader extends StatelessWidget {
  final UserModel? user;
  const _DrawerUserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final inicial = user?.nombre.isNotEmpty == true
        ? user!.nombre[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: _kDrawerSelectedBar.withAlpha(60),
            child: Text(
              inicial,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _kDrawerSelectedText),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.nombre ?? '',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: _kDrawerItemText),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (user?.rol != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    user!.rol.displayName.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kDrawerSelectedText,
                        letterSpacing: 1.2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Drawer Item ───────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  final bool Function(String location)? selectedIf;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
    this.selectedIf,
  });

  bool get _isSelected {
    if (selectedIf != null) return selectedIf!(current);
    if (route == RouteNames.dashboard) return current == route;
    return current.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          minVerticalPadding: 0,
          dense: true,
          leading: Icon(
            icon,
            size: 19,
            color: _isSelected ? _kDrawerSelectedText : _kDrawerItemText,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
              color: _isSelected ? _kDrawerSelectedText : _kDrawerItemText,
            ),
          ),
          selected: _isSelected,
          selectedTileColor: Colors.white.withAlpha(8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onTap: () {
            Navigator.of(context).pop();
            if (route == RouteNames.editarPerfil) {
              context.push(route);
            } else {
              context.go(route);
            }
          },
        ),
        if (_isSelected)
          Positioned(
            left: 0,
            top: 6,
            bottom: 6,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _kDrawerSelectedBar,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Drawer Logout Button ──────────────────────────────────────────────────────

class _DrawerLogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      leading: const Icon(Icons.logout_rounded,
          size: 19, color: Color(0xFFEF9A9A)),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFEF9A9A)),
      ),
      onTap: () async {
        Navigator.of(context).pop();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content:
                const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await context.read<AuthProvider>().cerrarSesion();
        }
      },
    );
  }
}
