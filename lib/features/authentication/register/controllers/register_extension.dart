import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/features/authentication/register/controllers/register_controller.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

extension RegisterExtension on RegisterController {
  void registerUser() async {
    try {
      await authApi.register(
        phone: phoneController.text,
        email: emailController.text,
        name: nameController.text,
      );

    Get.offNamed(
      Routes.verificationScreen,
      arguments: {"mobile": phoneController.text},
    );
  } catch (e) {
      AppSnack.error("Registration Error", e.toString());
    }
  }
}
