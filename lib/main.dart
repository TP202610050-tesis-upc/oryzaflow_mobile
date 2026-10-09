import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_service.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/sync/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/alert_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Transparent system bars — prevents the seed-color green from bleeding
  // through the status bar and system navigation bar areas.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await configurarDependencias();
  // Ante un 401, el ApiClient resetea la sesión para que el router lleve a login.
  sl<ApiClient>().onUnauthorized = () => sl<AuthProvider>().sesionExpirada();
  // Cola de eventos sin señal (HU-010, CA-010-02): carga la cola persistida y escucha la red.
  final sync = sl<SyncService>();
  sync.estaAutenticado = () => sl<AuthProvider>().estaAutenticado;
  sync.usuarioActualEmail = () => sl<AuthProvider>().usuario?.email;
  await sync.init();
  // Carga la preferencia de notificaciones + estado del permiso del SO.
  await sl<NotificationsProvider>().cargar();
  // Push FCM (HU-012): canal con sonido, token del dispositivo ligado a la sesión y al switch de notificaciones.
  final push = sl<PushService>();
  push.habilitadas = sl<NotificationsProvider>().activadas;
  await push.init();
  sl<AuthProvider>().alIniciarSesion = () async {
    // HU-012: pedir el permiso del SO al entrar (si el usuario no apagó las notificaciones) y registrar el token.
    final notif = sl<NotificationsProvider>();
    if (notif.preferenciaActivada && !notif.permisoConcedido) {
      await notif.setActivadas(true); // solicita el permiso; su gancho registra el token si se concede
    } else {
      push.habilitadas = notif.activadas;
      await push.registrar();
    }
    // Con sesión abierta, drenar lo que haya quedado en cola.
    unawaited(sync.sincronizar());
  };
  sl<AuthProvider>().alCerrarSesion = push.desregistrar;
  sl<NotificationsProvider>().alCambiar = (activadas) async {
    push.habilitadas = activadas;
    if (activadas) {
      await push.registrar();
    } else {
      await push.desregistrar();
    }
  };
  await initializeDateFormatting('es', null);
  runApp(const OryzaFlowApp());
}

class OryzaFlowApp extends StatefulWidget {
  const OryzaFlowApp({super.key});

  @override
  State<OryzaFlowApp> createState() => _OryzaFlowAppState();
}

class _OryzaFlowAppState extends State<OryzaFlowApp> with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<int>? _subSincronizados;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter(sl<AuthProvider>());
    // Tocar una notificación lleva a la pantalla de alertas.
    sl<PushService>().onAbrirAlertas = () => _appRouter.router.go(RouteNames.alertas);
    // Aviso global al terminar una sincronización (HU-010, CA-010-02).
    _subSincronizados = sl<SyncService>().sincronizados.listen((n) {
      _messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(n == 1 ? '1 evento sincronizado' : '$n eventos sincronizados'),
        backgroundColor: AppColors.verde,
      ));
    });
  }

  @override
  void dispose() {
    _subSincronizados?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver a la app (p. ej. tras salir del modo avión) se intenta drenar la cola.
    if (state == AppLifecycleState.resumed) unawaited(sl<SyncService>().sincronizar());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<AuthProvider>()),
        ChangeNotifierProvider.value(value: sl<ThemeProvider>()),
        ChangeNotifierProvider.value(value: sl<NotificationsProvider>()),
        ChangeNotifierProvider.value(value: sl<SyncService>()),
        ChangeNotifierProvider(create: (_) => sl<AlertProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp.router(
          title: AppStrings.appNombre,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routerConfig: _appRouter.router,
          scaffoldMessengerKey: _messengerKey,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
