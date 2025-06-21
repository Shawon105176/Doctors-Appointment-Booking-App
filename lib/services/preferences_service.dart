import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:doctor_appointments/models/user.dart';

class PreferencesService extends GetxService {  static const String keyUserId = 'userId';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserName = 'userName';
  static const String keyUserData = 'userData';
  static const String keyDarkMode = 'darkMode';
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications';
  static const String keyFirstTime = 'firstTime';

  late final SharedPreferences _prefs;

  static Future<PreferencesService> init() async {
    final instance = PreferencesService();
    instance._prefs = await SharedPreferences.getInstance();
    return instance;
  }

  // User management methods
  Future<void> saveUser(User user) async {
    await _prefs.setString(keyUserData, jsonEncode(user.toMap()));
    await _prefs.setInt(keyUserId, user.id ?? 0);
    await _prefs.setString(keyUserEmail, user.email);
    await _prefs.setString(keyUserName, user.name);
  }

  User? getUser() {
    final userData = _prefs.getString(keyUserData);
    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        return User.fromMap(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(keyUserData);
    await _prefs.remove(keyUserId);
    await _prefs.remove(keyUserEmail);
    await _prefs.remove(keyUserName);
  }

  // Basic preference methods
  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(keyUserId, userId);
  }

  Future<int?> getUserId() async {
    return _prefs.getInt(keyUserId);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    return _prefs.getString(keyUserEmail);
  }

  Future<void> saveUserName(String name) async {
    await _prefs.setString(keyUserName, name);
  }

  Future<String?> getUserName() async {
    return _prefs.getString(keyUserName);
  }

  // Settings methods
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(keyDarkMode, value);
  }

  bool getDarkMode() {
    return _prefs.getBool(keyDarkMode) ?? false;
  }

  bool isDarkMode() {
    return getDarkMode();
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(keyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(keyLanguage) ?? 'en';
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(keyNotifications, value);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(keyNotifications) ?? true;
  }

  // First time user methods
  Future<void> setFirstTime(bool value) async {
    await _prefs.setBool(keyFirstTime, value);
  }

  bool getFirstTime() {
    return _prefs.getBool(keyFirstTime) ?? true;
  }

  bool isFirstTime() {
    return getFirstTime();
  }

  // Generic methods for controllers
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }  Future<void> clearUserData() async {
    await removeUser();
  }
}