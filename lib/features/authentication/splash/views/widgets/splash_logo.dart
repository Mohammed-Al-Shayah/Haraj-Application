import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.harajAdenLogo, height: 84, width: 120);
  }
}
