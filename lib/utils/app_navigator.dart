import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor_appointments/screens/onboarding/onboarding_screen.dart';
import 'package:doctor_appointments/screens/auth/login_screen.dart';
import 'package:doctor_appointments/services/preferences_service.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      final prefsService = Get.find<PreferencesService>();
        // Check if it's the first time user is opening the app
      bool isFirstTime = prefsService.isFirstTime();
      print('DEBUG: Is first time: $isFirstTime'); // Debug log
      
      // Force onboarding for testing - remove this line later
      return const OnboardingScreen();
      
      /*
      if (isFirstTime) {
        return const OnboardingScreen();
      } else {
        return const LoginScreen();
      }
      */
    } catch (e) {
      print('DEBUG: Error in AppNavigator: $e');
      // Fallback to onboarding screen if there's an error
      return const OnboardingScreen();
    }
  }
}
