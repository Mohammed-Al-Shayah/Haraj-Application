import 'package:get/get.dart';
import '../../../../core/routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(Routes.onboardingScreen);
  }
}
