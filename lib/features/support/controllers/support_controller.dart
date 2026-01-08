import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/network/error/error_model.dart';
import 'package:haraj_adan_app/domain/entities/support_chat_entity.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportController extends GetxController {
  final SupportRepository repository;

  SupportController(this.repository);

  final chats = <SupportChatEntity>[].obs;

  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final searchController = TextEditingController();

  int _page = 1;
  static const int _pageSize = 10;
  bool _isHandlingUnauthorized = false;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadChats(reset: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadChats({bool reset = false}) async {
    if (reset) {
      _page = 1;
      chats.clear();
      hasMore.value = true;
    }

    if (!hasMore.value && !reset) return;

    if (reset) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    final search = searchController.text.trim();

    try {
      final result = await repository.getChats(
        page: _page,
        limit: _pageSize,
        search: search.isEmpty ? null : search,
      );

      if (reset) {
        chats.assignAll(result.items);
      } else {
        chats.addAll(result.items);
      }

      hasMore.value = result.hasMore;
      _page = result.page + 1;
    } on ErrorModel catch (error) {
      _log('loadChats error', error);
      _handleError(error, title: AppStrings.supportTitle);
    } catch (error, stack) {
      _log('loadChats unexpected', {'error': error, 'stack': stack});
      AppSnack.error(
        AppStrings.errorTitle,
        'Unable to load chats',
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadChats(reset: true);
    });
  }

  void loadMore() {
    if (isLoading.value || isLoadingMore.value) return;
    loadChats();
  }

  void _log(String message, [dynamic data]) {
    // ignore: avoid_print
    print(
      '[SupportController] $message${data != null ? ' => $data' : ''}',
    );
  }

  void _handleError(ErrorModel error, {String? title}) {
    final header = title ?? AppStrings.errorTitle;
    if (_isUnauthorized(error)) {
      AppSnack.error(header, AppStrings.loginRequired);
      _handleUnauthorized();
      return;
    }
    AppSnack.error(header, error.message);
  }

  bool _isUnauthorized(ErrorModel error) {
    final status = error.status.toLowerCase();
    final message = error.message.toLowerCase();
    return status.contains('401') ||
        status.contains('unauthor') ||
        message.contains('401') ||
        message.contains('unauthor') ||
        message.contains('expired');
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('_accessToken');
    await prefs.remove('_loginToken');
    await prefs.remove('_userData');
    Get.offAllNamed(Routes.loginScreen);
  }
}
