import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/error/error_model.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:haraj_adan_app/core/network/network_info.dart';
import 'package:haraj_adan_app/features/authentication/email_verification/controllers/verification_extenstion.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

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
      AppSnack.error("No Internet", "Please check your connection");
      return;
    }

    if (otp.value.length != 6) {
      AppSnack.error("Error", "Please enter full OTP");
      return;
    }

    verifyUser();
  }

  void resendOtp() async {
    if (!formKey.currentState!.validate()) return;

    bool connected = await NetworkInfo().isConnected;
    if (!connected) {
      AppSnack.error("No Internet", "Please check your connection");
      return;
    }

    try {
      final args = Get.arguments;
      final phone = (args is Map ? args['mobile'] : null)?.toString().trim();
      if (phone == null || phone.isEmpty) {
        AppSnack.error("Error", "Missing phone number");
        return;
      }
      await authApi.resendOtp(phone: phone);
      AppSnack.success("Success", "OTP resent successfully");
    } on ErrorModel catch (e) {
      AppSnack.error("Error", e.message);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map && data['message'] != null)
              ? data['message'].toString()
              : (e.message ?? 'Unknown error');
      AppSnack.error("Error", message);
    } catch (e) {
      AppSnack.error("Error", "Something went wrong");
    }
  }
}
