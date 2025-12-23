import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountController extends GetxController {
  final currentLanguage = LocalizeAndTranslate.getLanguageCode();
  final AuthApi authApi = AuthApi(ApiClient(client: Dio()));

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final userName = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void onLogout() {
    authApi.logout();
  }

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("_userData");

    if (userJson != null) {
      final user = jsonDecode(userJson);

      userName.value = user['name'] ?? '';
      userEmail.value = user['email'] ?? '';
    }
  }
}
