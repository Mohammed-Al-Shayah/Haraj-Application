import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/network/network_info.dart';

enum ForgotPasswordState { initial, loading, success, error }

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  var forgotPasswordState = ForgotPasswordState.initial.obs;

  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(checkFieldsFilled);
  }

  void checkFieldsFilled() {
    isFormValid.value = emailController.text.isNotEmpty;
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
    super.onClose();
  }
}
