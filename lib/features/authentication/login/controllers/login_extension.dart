import 'package:haraj_adan_app/features/authentication/login/controllers/login_controller.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

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
      AppSnack.error("Login Error", e.toString());
    }
  }
}
