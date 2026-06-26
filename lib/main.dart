import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
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
  // Carga la preferencia de notificaciones + estado del permiso del SO.
  await sl<NotificationsProvider>().cargar();
  await initializeDateFormatting('es', null);
  runApp(const OryzaFlowApp());
}

class OryzaFlowApp extends StatefulWidget {
  const OryzaFlowApp({super.key});

  @override
  State<OryzaFlowApp> createState() => _OryzaFlowAppState();
}

class _OryzaFlowAppState extends State<OryzaFlowApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(sl<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<AuthProvider>()),
        ChangeNotifierProvider.value(value: sl<ThemeProvider>()),
        ChangeNotifierProvider.value(value: sl<NotificationsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AlertProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp.router(
          title: AppStrings.appNombre,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routerConfig: _appRouter.router,
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
