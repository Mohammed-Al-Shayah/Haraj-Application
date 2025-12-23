import 'package:get/get.dart';
import 'package:haraj_adan_app/features/authentication/login/controllers/login_controller.dart';

extension LoginExtension on LoginController {
  void loginUser() async {
    loginState.value = LoginState.loading;
    try {
      if (isEmailSelected.value) {
        await authApi.login(email: emailController.text);
      } else {
        await authApi.login(
          phone: "${countryCode.value}${phoneController.text}",
        );
      }

      loginState.value = LoginState.success;
    } catch (e) {
      loginState.value = LoginState.error;
      Get.snackbar("Login Error", e.toString());
    }
  }
}
