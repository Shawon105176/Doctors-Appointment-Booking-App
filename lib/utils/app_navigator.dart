import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor_appointments/screens/onboarding/onboarding_screen.dart';
import 'package:doctor_appointments/screens/auth/login_screen.dart';
import 'package:doctor_appointments/services/preferences_service.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsService = Get.find<PreferencesService>();
    
    // Check if it's the first time user is opening the app
    if (prefsService.isFirstTime()) {
      return const OnboardingScreen();
    } else {
      return const LoginScreen();
    }
  }
}
