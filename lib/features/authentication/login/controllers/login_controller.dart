import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:haraj_adan_app/features/authentication/login/controllers/login_extension.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import '../../../../core/network/network_info.dart';

enum LoginState { initial, loading, success, error }

class LoginController extends GetxController {
  final AuthApi authApi = AuthApi(ApiClient(client: Dio()));

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  var loginState = LoginState.initial.obs;
  var isEmailSelected = true.obs;
  var isFormValid = false.obs;
  var countryCode = '+967'.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(checkFieldsFilled);
    phoneController.addListener(checkFieldsFilled);
  }

  void checkFieldsFilled() {
    isFormValid.value =
        isEmailSelected.value
            ? emailController.text.isNotEmpty
            : phoneController.text.isNotEmpty;
  }

  void submitForm() async {
    if (!formKey.currentState!.validate()) return;
    bool connected = await NetworkInfo().isConnected;
    if (!connected) {
      AppSnack.error("No Internet", "Please check your connection");
      return;
    }
    loginUser();
    Get.offNamed(
      Routes.verificationScreen,
      arguments: {
        "mobile":
            isEmailSelected.value
                ? emailController.text
                : "${countryCode.value}${phoneController.text}",
      },
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
