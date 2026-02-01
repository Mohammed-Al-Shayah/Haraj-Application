import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountController extends GetxController {
  final RxString currentLanguage = ''.obs;
  final AuthApi authApi = AuthApi(ApiClient(client: Dio()));

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final isUpdating = false.obs;
  final isStatsLoading = false.obs;
  final publishedCount = 0.obs;
  final unpublishedCount = 0.obs;
  final rejectedCount = 0.obs;
  final featuredCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    currentLanguage.value = LocalizeAndTranslate.getLanguageCode();
    getUserData();
    loadAdsStats();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void onLogout() {
    authApi.logout();
  }

  void updateLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    LocalizeAndTranslate.setLanguageCode(languageCode);
    Get.updateLocale(Locale(languageCode));
  }

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("_userData");

    if (userJson != null) {
      final user = jsonDecode(userJson);

      userName.value = user['name'] ?? '';
      userEmail.value = user['email'] ?? '';
      userPhone.value = user['phone']?.toString() ?? '';

      nameController.text = userName.value;
      emailController.text = userEmail.value;
      phoneController.text = userPhone.value;
    }
  }

  Future<void> loadAdsStats() async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) return;

    try {
      isStatsLoading.value = true;
      final res = await authApi.api.get('${ApiEndpoints.userAdsStats}/$userId');
      final data =
          res['data'] is Map<String, dynamic>
              ? res['data'] as Map<String, dynamic>
              : res;

      int asInt(dynamic value) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        return int.tryParse(value?.toString() ?? '') ?? 0;
      }

      // Support both old and new API keys.
      publishedCount.value = asInt(data['published'] ?? data['totalPublished']);
      unpublishedCount.value = asInt(
        data['unpublished'] ?? data['totalUnPublished'],
      );
      rejectedCount.value = asInt(data['rejected'] ?? data['totalRejected']);
      featuredCount.value = asInt(data['featured'] ?? data['totalFeatured']);
    } catch (_) {
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.profileNameRequired);
      return;
    }

    if (email.isEmpty && phone.isEmpty) {
      AppSnack.error(
        AppStrings.errorTitle,
        AppStrings.profileContactRequired,
      );
      return;
    }

    isUpdating.value = true;
    try {
      final res = await authApi.updateProfile(
        name: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
      );

      final data =
          res['data'] is Map<String, dynamic>
              ? res['data'] as Map<String, dynamic>
              : res;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("_userData", jsonEncode(data));

      userName.value = data['name']?.toString() ?? name;
      userEmail.value = data['email']?.toString() ?? email;
      userPhone.value = data['phone']?.toString() ?? phone;

      nameController.text = userName.value;
      emailController.text = userEmail.value;
      phoneController.text = userPhone.value;

      AppSnack.success(
        AppStrings.successTitle,
        AppStrings.profileUpdateSuccess,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message']?.toString() ??
              AppStrings.profileUpdateFailed;
      AppSnack.error(AppStrings.errorTitle, message);
    } catch (_) {
      AppSnack.error(
        AppStrings.errorTitle,
        AppStrings.profileUpdateFailed,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
