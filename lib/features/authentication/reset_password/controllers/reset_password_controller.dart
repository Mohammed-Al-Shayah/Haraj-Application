import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/network/network_info.dart';

enum ResetPasswordState { initial, loading, success, error }

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var resetPasswordState = ResetPasswordState.initial.obs;

  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(checkFieldsFilled);
    passwordController.addListener(checkFieldsFilled);
  }

  void checkFieldsFilled() {
    isFormValid.value =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      bool connected = await NetworkInfo().isConnected;
      if (connected) {
        registerUser();
      } else {}
    }
  }

  void registerUser() async {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
