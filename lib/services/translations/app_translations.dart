import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'translations/en_US.dart';
import 'translations/es_ES.dart';
import 'translations/fr_FR.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'es_ES': esES,
        'fr_FR': frFR,
      };
}

class LocaleService extends GetxService {
  final _locale = const Locale('en', 'US').obs;
  final supportedLocales = const [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];

  Locale get locale => _locale.value;

  void changeLocale(String languageCode, String countryCode) {
    _locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(_locale.value);
  }
}
