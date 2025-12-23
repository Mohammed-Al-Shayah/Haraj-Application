import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import '../../controllers/splash_controller.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_title.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.primary));
    Get.put(SplashController());

    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SplashLogo(),
            SizedBox(height: 8),
            SplashTitle(),
          ],
        ),
      ),
    );
  }
}
