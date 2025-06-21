import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor_appointments/models/user.dart';
import 'package:doctor_appointments/services/database_helper.dart';
import 'package:doctor_appointments/services/preferences_service.dart';

class UserController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PreferencesService _prefsService = Get.find<PreferencesService>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isDarkMode = false.obs;
  final RxString selectedLanguage = 'English'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    try {
      currentUser.value = _prefsService.getUser();
      isDarkMode.value = _prefsService.getDarkMode();
      selectedLanguage.value = _prefsService.getString('language') ?? 'English';
      notificationsEnabled.value = _prefsService.getBool('notifications') ?? true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: ${e.toString()}');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      
      if (currentUser.value == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = currentUser.value!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // Update in database
      final result = await _dbHelper.updateUser(updatedUser.toMap());
      
      if (result > 0) {
        // Update in local storage
        await _prefsService.saveUser(updatedUser);
        currentUser.value = updatedUser;
        
        Get.snackbar('Success', 'Profile updated successfully');
        return true;
      } else {
        throw Exception('Failed to update profile in database');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      
      if (currentUser.value == null) {
        throw Exception('No user logged in');
      }

      // Verify current password
      if (currentUser.value!.password != currentPassword) {
        Get.snackbar('Error', 'Current password is incorrect');
        return false;
      }

      final updatedUser = currentUser.value!.copyWith(password: newPassword);
      
      // Update in database
      final result = await _dbHelper.updateUser(updatedUser.toMap());
      
      if (result > 0) {
        // Update in local storage
        await _prefsService.saveUser(updatedUser);
        currentUser.value = updatedUser;
        
        Get.snackbar('Success', 'Password changed successfully');
        return true;
      } else {
        throw Exception('Failed to update password in database');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      await _prefsService.setDarkMode(isDarkMode.value);
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle dark mode: ${e.toString()}');
    }
  }

  Future<void> changeLanguage(String language) async {
    try {
      selectedLanguage.value = language;
      await _prefsService.setString('language', language);
      
      // Update app locale based on language
      Locale locale;
      switch (language.toLowerCase()) {
        case 'spanish':
        case 'español':
          locale = const Locale('es', 'ES');
          break;
        case 'french':
        case 'français':
          locale = const Locale('fr', 'FR');
          break;
        default:
          locale = const Locale('en', 'US');
      }
      
      Get.updateLocale(locale);
    } catch (e) {
      Get.snackbar('Error', 'Failed to change language: ${e.toString()}');
    }
  }

  Future<void> toggleNotifications() async {
    try {
      notificationsEnabled.value = !notificationsEnabled.value;
      await _prefsService.setBool('notifications', notificationsEnabled.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle notifications: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Clear user data from preferences
      await _prefsService.removeUser();
      
      // Reset controller state
      currentUser.value = null;
      isDarkMode.value = false;
      selectedLanguage.value = 'English';
      notificationsEnabled.value = true;
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettings({
    bool? darkMode,
    bool? notifications,
    String? language,
  }) async {
    try {
      if (darkMode != null) {
        await toggleDarkMode();
      }
      
      if (notifications != null) {
        await toggleNotifications();
      }
      
      if (language != null) {
        await changeLanguage(language);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings: ${e.toString()}');
    }
  }

  // Helper method to check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  // Get user display name
  String get userDisplayName => currentUser.value?.name ?? 'User';

  // Get user email
  String get userEmail => currentUser.value?.email ?? '';
}