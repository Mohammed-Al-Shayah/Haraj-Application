import 'package:flutter/widgets.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Localization {
  // Method to initialize localization
  static Future<void> initialize() async {
    await LocalizeAndTranslate.init(
      assetLoader: const AssetLoaderRootBundleJson('assets/lang'),
      supportedLanguageCodes: const <String>['ar', 'en'],
    );
  }

  // Method to determine the font family based on the current context
  static String getFontFamily(BuildContext context) {
    return context.locale.languageCode == 'ar' ? 'Cairo' : 'Inter';
  }

  // Method to wrap child with localization direction builder
  static Widget directionBuilder(BuildContext context, Widget? child) {
    return LocalizeAndTranslate.directionBuilder(context, child);
  }

  // **New Helper for the builder**
  static Widget builder(BuildContext context, Widget? child) =>
      directionBuilder(context, child);
}
