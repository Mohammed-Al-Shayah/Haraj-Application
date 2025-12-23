import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../../../core/theme/assets.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final image = currentLanguage == 'ar'
        ? AppAssets.onboardingArImage
        : AppAssets.onboardingEnImage;

    final isTablet = MediaQuery.of(context).size.width > 600;

    return isTablet
        ? Center(
            child: Image.asset(image),
          )
        : Image.asset(image, height: MediaQuery.of(context).size.height);
  }
}
