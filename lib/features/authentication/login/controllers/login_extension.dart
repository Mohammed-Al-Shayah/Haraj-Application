import 'package:haraj_adan_app/core/network/error/error_model.dart';
import 'package:haraj_adan_app/features/authentication/login/controllers/login_controller.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

extension LoginExtension on LoginController {
  Future<bool> loginUser() async {
    loginState.value = LoginState.loading;
    try {
      final isEmail = isEmailSelected.value;
      final phone =
          isEmail ? null : "${countryCode.value}${phoneController.text}";
      if (isEmail) {
        await authApi.login(email: emailController.text);
      } else {
        await authApi.login(phone: phone);
      }

      if (phone != null && phone.isNotEmpty) {
        try {
          await authApi.resendOtp(phone: phone);
        } on ErrorModel catch (e) {
          if (!e.message.contains('otp.cooldown')) {
            AppSnack.error("OTP Error", e.message);
          }
        } catch (_) {
          // Ignore resend failures so login can proceed.
        }
      }

      loginState.value = LoginState.success;
      return true;
    } on ErrorModel catch (e) {
      loginState.value = LoginState.error;
      AppSnack.error("Login Error", e.message);
      return false;
    } catch (e) {
      loginState.value = LoginState.error;
      AppSnack.error("Login Error", e.toString());
      return false;
    }
  }
}
