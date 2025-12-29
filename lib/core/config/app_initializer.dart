import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../theme/color.dart';
import '../utils/localization.dart';

Future<void> appInitializer() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load .env file
  // await dotenv.load();

  /// Initialize localization
  await Localization.initialize();

  /// Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor:
          ColorScheme.fromSeed(seedColor: AppColors.primary).surface,
    ),
  );

  /// Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Initial locale to English
  // await LocalizeAndTranslate.setLocale(const Locale('en'));

  const accessToken =
      'pk.eyJ1IjoiaGFyYWphZGVuIiwiYSI6ImNtaDF4aHJ5eTBiMnkya3M5cjlleXI0aGQifQ.JT420uEjV8aaVurHgEXIoA';
  MapboxOptions.setAccessToken(accessToken);
}
