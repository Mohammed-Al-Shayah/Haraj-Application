import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:haraj_adan_app/features/authentication/register/controllers/register_extension.dart';
import '../../../../../../core/network/network_info.dart';

enum RegistrationState { initial, loading, success, error }

class RegisterController extends GetxController {
  final AuthApi authApi = AuthApi(ApiClient(client: Dio()));
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  var registrationState = RegistrationState.initial.obs;

  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(checkFieldsFilled);
    emailController.addListener(checkFieldsFilled);
    phoneController.addListener(checkFieldsFilled);
  }

  void checkFieldsFilled() {
    isFormValid.value = nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      bool connected = await NetworkInfo().isConnected;
      if (connected) {
        registerUser();
      } else {
        Get.snackbar("No Internet", "Please check your connection");
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
