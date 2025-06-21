import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doctor_appointments/utils/theme.dart';
import 'package:doctor_appointments/screens/splash/splash_screen.dart';
import 'package:doctor_appointments/services/mock_notification_service.dart';
import 'package:doctor_appointments/services/translations/app_translations.dart';
import 'package:doctor_appointments/services/preferences_service.dart';
import 'package:doctor_appointments/controllers/user_controller.dart';
import 'package:doctor_appointments/controllers/appointment_controller.dart';
import 'package:doctor_appointments/controllers/search_controller.dart' as doctor_search;
import 'package:doctor_appointments/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {    // Initialize services
    final prefsService = await PreferencesService.init();
    Get.put(prefsService);

    final dbHelper = DatabaseHelper();
    Get.put(dbHelper);

    final notificationService = MockNotificationService();
    await notificationService.initialize();
    Get.put(notificationService);final localeService = LocaleService();
    Get.put(localeService);    // Initialize controllers
    Get.put(UserController());
    Get.put(AppointmentController());
    Get.put(doctor_search.SearchController());

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Fallback to basic app
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final localeService = Get.find<LocaleService>();
      
      return GetMaterialApp(
        title: 'Doctor Appointments',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Localization
        translations: AppTranslations(),
        locale: localeService.locale,
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: localeService.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        home: const SplashScreen(),
        defaultTransition: Transition.fadeIn,
      );
    } catch (e) {
      debugPrint('Error building app: $e');
      // Fallback to basic Material app
      return MaterialApp(
        title: 'Doctor Appointments',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Doctor Appointments App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
