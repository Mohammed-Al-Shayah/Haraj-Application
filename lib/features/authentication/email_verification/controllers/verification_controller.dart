import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:haraj_adan_app/core/network/network_info.dart';
import 'package:haraj_adan_app/features/authentication/email_verification/controllers/verification_extenstion.dart';

enum EmailVerificationState { initial, loading, success, error }

class VerificationController extends GetxController {
  final AuthApi authApi = AuthApi(ApiClient(client: Dio()));
  final formKey = GlobalKey<FormState>();

  var otp = ''.obs;
  var isFormValid = false.obs;
  var emailVerificationState = EmailVerificationState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    ever(otp, (_) => _checkFormValidity());
  }

  void _checkFormValidity() {
    isFormValid.value = otp.value.length == 6;
  }

  void submitForm() async {
    if (!formKey.currentState!.validate()) return;

    bool connected = await NetworkInfo().isConnected;
    if (!connected) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }

    if (otp.value.length != 6) {
      Get.snackbar("Error", "Please enter full OTP");
      return;
    }

    verifyUser();
  }

  void resendOtp() async {
    if (!formKey.currentState!.validate()) return;

    bool connected = await NetworkInfo().isConnected;
    if (!connected) {
      Get.snackbar("No Internet", "Please check your connection", backgroundColor: Colors.red);
      return;
    }

    await authApi.resendOtp(phone: Get.arguments['mobile']);
    Get.snackbar(
      "Success",
      "OTP resent successfully",
      backgroundColor: Colors.green,
    );
  }
}
