import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/color.dart';
import '../../controllers/onboarding_controller.dart';
import '../widgets/background_image.dart';
import '../widgets/bottom_box.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.primary));
    Get.put(OnboardingController());

    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          BackgroundImage(),
          Align(alignment: Alignment.bottomCenter, child: BottomBox()),
        ],
      ),
    );
  }
}
