import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/reports/presentation/dashboard_page.dart';

class SessionGate extends GetView<AuthController> {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isRestoring.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return controller.user.value == null
          ? const OnboardingPage()
          : const DashboardPage();
    });
  }
}
