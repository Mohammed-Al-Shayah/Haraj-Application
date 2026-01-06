import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/entities/support_chat_entity.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';

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

    final result = await repository.getChats(
      page: _page,
      limit: _pageSize,
      search: search.isEmpty ? null : search,
      userId: null, // keep backend compatibility
    );

    if (reset) {
      chats.assignAll(result.items);
    } else {
      chats.addAll(result.items);
    }

    hasMore.value = result.hasMore;
    _page = result.page + 1;

    isLoading.value = false;
    isLoadingMore.value = false;
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
}
