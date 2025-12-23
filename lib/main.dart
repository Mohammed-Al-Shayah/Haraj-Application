import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'core/config/app_initializer.dart';
import 'core/routes/routes.dart';
import 'core/theme/color.dart';
import 'core/theme/strings.dart';
import 'core/utils/localization.dart';

void main() async {
  await appInitializer();
  runApp(const HarajAdanApp());
}

class HarajAdanApp extends StatelessWidget {
  const HarajAdanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LocalizedApp(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          fontFamily: Localization.getFontFamily(context),
          useMaterial3: true,
        ),
        localizationsDelegates: context.delegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: Localization.builder,
        initialRoute: Routes.splash,
        getPages: Routes.routes,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
