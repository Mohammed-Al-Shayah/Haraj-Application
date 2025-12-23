import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

enum OnboardingState { initial, loading, success, error }

class OnboardingController extends GetxController {
  var selectedLanguage =
      (LocalizeAndTranslate.getLanguageCode() == 'ar' ? 'Arabic' : 'English')
          .obs;

  void updateLanguage(String language) {
    selectedLanguage.value = language;
    LocalizeAndTranslate.setLanguageCode(language == 'Arabic' ? 'ar' : 'en');
    Get.updateLocale(
      language == 'Arabic' ? const Locale('ar') : const Locale('en'),
    );
  }
}
