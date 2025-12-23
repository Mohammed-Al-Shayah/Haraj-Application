import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/verification_controller.dart';

extension VerificationExtenstion on VerificationController {
  void verifyUser() async {
    emailVerificationState.value = EmailVerificationState.loading;

    try {
      final res = await authApi.verifyOtp(otp: otp.value);

      final tokens = res['tokens'];
      final userData = res['data'];
      final message = res['message'] ?? 'OTP verification failed';

      if (tokens != null && tokens['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("_accessToken", tokens["access_token"]);
        await prefs.setString("_refreshToken", tokens["refresh_token"]);

        if (userData != null) {
          await prefs.setString("_userData", jsonEncode(userData));
        }

        emailVerificationState.value = EmailVerificationState.success;
        Get.offNamed(Routes.homeScreen);
        return;
      }

      emailVerificationState.value = EmailVerificationState.error;
      Get.snackbar("Verification Error", message);

    } on DioException catch (e) {
      final data = e.response?.data;
      String message = "Unknown error";

      if (data is Map && data['message'] != null) {
        message = data['message'];
      } else if (e.message != null) {
        message = e.message!;
      }

      emailVerificationState.value = EmailVerificationState.error;
      Get.snackbar("Verification Error", message);

    } catch (e) {
      emailVerificationState.value = EmailVerificationState.error;

      String message = "Something went wrong";

      if (e is Exception) {
        final errorString = e.toString();
        if (errorString.contains("Exception: ")) {
          message = errorString.replaceFirst("Exception: ", "");
        } else {
          message = errorString;
        }
      }

      Get.snackbar("Verification Error", message);
      if (kDebugMode) {
        print("Unknown error: $e");
      }
    }
  }
}
