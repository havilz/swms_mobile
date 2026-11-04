import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/reports/data/report_repository.dart';
import '../features/reports/presentation/dashboard_controller.dart';
import '../features/reports/presentation/report_detail_controller.dart';
import '../features/reports/presentation/report_form_controller.dart';
import '../features/reports/presentation/report_form_page.dart';
import '../features/reports/presentation/report_detail_page.dart';
import '../features/reports/presentation/dashboard_page.dart';
import '../features/reports/presentation/map_picker_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/presentation/profile_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../shared/theme/app_theme.dart';
import 'session_gate.dart';

class SwmsApp extends StatelessWidget {
  const SwmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.fromEnvironment();
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final authRepository = AuthRepository(apiClient.dio);
    final reportRepository = ReportRepository(apiClient.dio);

    return GetMaterialApp(
      title: 'SWMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: BindingsBuilder(() {
        Get.put<AppConfig>(config, permanent: true);
        Get.put<TokenStorage>(tokenStorage, permanent: true);
        Get.put<AuthRepository>(authRepository, permanent: true);
        Get.put<ReportRepository>(reportRepository, permanent: true);
        Get.put<AuthController>(
          AuthController(authRepository, tokenStorage),
          permanent: true,
        );
        Get.put<DashboardController>(
          DashboardController(reportRepository),
          permanent: true,
        );
      }),
      home: const SessionGate(),
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/home', page: () => const DashboardPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/reports/map', page: () => const MapPickerPage()),
        GetPage(
          name: '/reports/new',
          page: () => const ReportFormPage(),
          binding: BindingsBuilder(() {
            Get.put(ReportFormController(Get.find<ReportRepository>()));
          }),
        ),
        GetPage(
          name: '/reports/edit',
          page: () => const ReportFormPage(),
          binding: BindingsBuilder(() {
            Get.put(ReportFormController(Get.find<ReportRepository>()));
          }),
        ),
        GetPage(
          name: '/reports/detail',
          page: () => const ReportDetailPage(),
          binding: BindingsBuilder(() {
            Get.put(ReportDetailController(Get.find<ReportRepository>()));
          }),
        ),
      ],
    );
  }
}
