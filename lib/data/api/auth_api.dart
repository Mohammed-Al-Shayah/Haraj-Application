import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  final ApiClient api;

  AuthApi(this.api);

  /// REGISTER: send OTP, then navigate to OTP screen
  Future<void> register({
    required String phone,
    required String email,
    required String name,
  }) async {
    final res = await api.post(
      ApiEndpoints.register,
      data: {"phone": phone, "email": email, "name": name},
    );

    if (kDebugMode) {
      print("REGISTER RESPONSE: $res");
    }
  }

  /// LOGIN: send OTP, then navigate to OTP screen
  Future<void> login({String? phone, String? email}) async {
    assert(
      (phone != null && email == null) || (phone == null && email != null),
      "You must provide either phone or email, not both",
    );

    final res = await api.post(
      ApiEndpoints.login,
      data: {
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
      },
    );

    if (kDebugMode) {
      print("LOGIN RESPONSE: $res");
    }
  }

  /// RESPOND OTP: resend OTP to phone
  Future<void> resendOtp({required String phone}) async {
    await api.post(ApiEndpoints.resendOtp, data: {"phone": phone});
  }

  /// UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? email,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };

    return await api.patch(ApiEndpoints.updateProfile, data: payload);
  }

  /// VERIFY OTP: save token & navigate to home
  Future<Map<String, dynamic>> verifyOtp({required String otp}) async {
    try {
      final res = await api.post(ApiEndpoints.verifyOtp, data: {"otp": otp});

      final responseData = res['data'] is Map ? res['data'] : res;

      final tokens = res['tokens'] ?? responseData['tokens'];
      final message = res['message'] ?? responseData['message'] ?? 'Unknown';

      if (tokens != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("_accessToken", tokens['access_token'] ?? '');
        await prefs.setString("_refreshToken", tokens['refresh_token'] ?? '');
        return {
          "success": true,
          "tokens": tokens,
          "message": message,
          "data": responseData,
        };
      }

      return {"success": false, "message": message};
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map<String, dynamic>)
              ? data['message'] ?? data['error'] ?? 'Unknown error'
              : e.message ?? 'Unknown error';
      return {"success": false, "message": message};
    } catch (e) {
      return {"success": false, "message": "Something went wrong"};
    }
  }

  /// LOGOUT: remove token & navigate to login
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("_accessToken");

      if (token != null && token.isNotEmpty) {
        await api.get(
          ApiEndpoints.logout,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }

      await prefs.clear();

      Get.offAllNamed(Routes.loginScreen);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map<String, dynamic>)
              ? data['message'] ?? data['error'] ?? 'Unknown error'
              : e.message ?? 'Unknown error';

      AppSnack.error('Logout Error', message);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.loginScreen);
    } catch (e) {
      AppSnack.error('Logout Error', 'Something went wrong');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.loginScreen);
    }
  }

  /// GOOGLE AUTH: redirect to google auth page
  Future<void> googleAuthRedirect() async {
    try {
      final options = Options(headers: {'Content-Type': 'application/json'});

      await api.get(ApiEndpoints.googleAuth, options: options);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map<String, dynamic>)
              ? data['message'] ?? data['error'] ?? 'Unknown error'
              : e.message ?? 'Unknown error';

      AppSnack.error('Google Auth Error', message);
    } catch (e) {
      AppSnack.error('Google Auth Error', 'Something went wrong');
    }
  }
}
