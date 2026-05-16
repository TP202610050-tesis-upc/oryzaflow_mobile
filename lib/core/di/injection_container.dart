import 'package:get_it/get_it.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/silo_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../repositories/i_alert_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_batch_repository.dart';
import '../../repositories/i_drying_profile_repository.dart';
import '../../repositories/i_node_repository.dart';
import '../../repositories/i_report_repository.dart';
import '../../repositories/i_settings_repository.dart';
import '../../repositories/i_silo_repository.dart';
import '../../repositories/i_user_repository.dart';
import '../../repositories/i_variety_repository.dart';
import '../../repositories/mock/mock_alert_repository.dart';
import '../../repositories/mock/mock_auth_repository.dart';
import '../../repositories/mock/mock_batch_repository.dart';
import '../../repositories/mock/mock_drying_profile_repository.dart';
import '../../repositories/mock/mock_node_repository.dart';
import '../../repositories/mock/mock_report_repository.dart';
import '../../repositories/mock/mock_settings_repository.dart';
import '../../repositories/mock/mock_silo_repository.dart';
import '../../repositories/mock/mock_user_repository.dart';
import '../../repositories/mock/mock_variety_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configurarDependencias() async {
  // ── Repositories (LazySingleton — mock state is shared across providers) ──
  sl.registerLazySingleton<IAuthRepository>(() => MockAuthRepository());
  sl.registerLazySingleton<IAlertRepository>(() => MockAlertRepository());
  sl.registerLazySingleton<ISiloRepository>(() => MockSiloRepository());
  sl.registerLazySingleton<IVarietyRepository>(() => MockVarietyRepository());
  sl.registerLazySingleton<IBatchRepository>(() => MockBatchRepository());
  sl.registerLazySingleton<INodeRepository>(() => MockNodeRepository());
  sl.registerLazySingleton<IDryingProfileRepository>(
      () => MockDryingProfileRepository());
  sl.registerLazySingleton<IReportRepository>(() => MockReportRepository());
  sl.registerLazySingleton<IUserRepository>(() => MockUserRepository());
  sl.registerLazySingleton<ISettingsRepository>(
      () => MockSettingsRepository());

  // ── Providers ──
  // AuthProvider and ThemeProvider are singletons — app-wide state
  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<IAuthRepository>()));
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // All others are Factory — created fresh per screen, disposed on pop
  sl.registerFactory<DashboardProvider>(() => DashboardProvider(
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
