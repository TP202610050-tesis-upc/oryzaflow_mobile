import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/token_storage.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/silo_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../repositories/i_alert_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_batch_repository.dart';
import '../../repositories/i_dashboard_repository.dart';
import '../../repositories/i_drying_profile_repository.dart';
import '../../repositories/i_node_repository.dart';
import '../../repositories/i_report_repository.dart';
import '../../repositories/i_settings_repository.dart';
import '../../repositories/i_silo_repository.dart';
import '../../repositories/i_user_repository.dart';
import '../../repositories/i_variety_repository.dart';
import '../../repositories/mock/mock_settings_repository.dart';
import '../../repositories/api/real_auth_repository.dart';
import '../../repositories/api/real_alert_repository.dart';
import '../../repositories/api/real_batch_repository.dart';
import '../../repositories/api/real_dashboard_repository.dart';
import '../../repositories/api/real_silo_repository.dart';
import '../../repositories/api/real_variety_repository.dart';
import '../../repositories/api/real_drying_profile_repository.dart';
import '../../repositories/api/real_node_repository.dart';
import '../../repositories/api/real_user_repository.dart';
import '../../repositories/api/real_report_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configurarDependencias() async {
  // ── Infraestructura de red ──
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<TokenStorage>()));

  // ── Repositories (todos REALES salvo settings, que son preferencias locales) ──
  sl.registerLazySingleton<IAuthRepository>(
      () => RealAuthRepository(sl<ApiClient>(), sl<TokenStorage>()));
  sl.registerLazySingleton<IDashboardRepository>(
      () => RealDashboardRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IAlertRepository>(
      () => RealAlertRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IBatchRepository>(
      () => RealBatchRepository(sl<ApiClient>()));
  sl.registerLazySingleton<ISiloRepository>(
      () => RealSiloRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IVarietyRepository>(
      () => RealVarietyRepository(sl<ApiClient>()));
  sl.registerLazySingleton<INodeRepository>(
      () => RealNodeRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IDryingProfileRepository>(
      () => RealDryingProfileRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IReportRepository>(
      () => RealReportRepository(sl<ApiClient>()));
  sl.registerLazySingleton<IUserRepository>(
      () => RealUserRepository(sl<ApiClient>()));

  // Settings = preferencias de app (tema/idioma/notif), sin backend → local/mock.
  sl.registerLazySingleton<ISettingsRepository>(
      () => MockSettingsRepository());

  // ── Providers ──
  // AuthProvider and ThemeProvider are singletons — app-wide state
  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<IAuthRepository>()));
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  sl.registerLazySingleton<NotificationsProvider>(
      () => NotificationsProvider());

  // All others are Factory — created fresh per screen, disposed on pop
  sl.registerFactory<DashboardProvider>(() => DashboardProvider(
        sl<IDashboardRepository>(),
        sl<INodeRepository>(),
        sl<IBatchRepository>(),
        sl<IAlertRepository>(),
        sl<ISiloRepository>(),
      ));
  sl.registerFactory<AlertProvider>(
      () => AlertProvider(sl<IAlertRepository>()));
  sl.registerFactory<SiloProvider>(() => SiloProvider(
        sl<ISiloRepository>(),
        sl<IVarietyRepository>(),
        sl<IDryingProfileRepository>(),
      ));
  sl.registerFactory<BatchProvider>(() => BatchProvider(
        sl<IBatchRepository>(),
        sl<ISiloRepository>(),
        sl<IVarietyRepository>(),
        sl<IDryingProfileRepository>(),
        sl<INodeRepository>(),
      ));
  sl.registerFactory<MonitoringProvider>(
      () => MonitoringProvider(sl<INodeRepository>()));
  sl.registerFactory<ReportProvider>(() => ReportProvider(
        sl<IReportRepository>(),
        sl<ISiloRepository>(),
        sl<IVarietyRepository>(),
      ));
  sl.registerFactory<UserManagementProvider>(
      () => UserManagementProvider(sl<IUserRepository>()));
  sl.registerFactory<SettingsProvider>(
      () => SettingsProvider(sl<ISettingsRepository>()));
}
