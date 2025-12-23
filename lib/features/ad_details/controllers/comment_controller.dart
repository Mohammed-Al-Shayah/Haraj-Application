import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/entities/comment_entity.dart';
import 'package:haraj_adan_app/domain/repositories/comment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_details_controller.dart';

class CommentsController extends GetxController {
  final CommentsRepository repository;

  CommentsController(this.repository);

  String? _userName;

  final comments = <CommentEntity>[].obs;

  final isLoading = false.obs;
  final isPosting = false.obs;

  final page = 1.obs;
  final total = 0.obs;
  final hasMore = true.obs;

  final error = ''.obs;

  final TextEditingController commentTextController = TextEditingController();

  late int adId;
  int? _userId;

  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    adId = _readAdId();
    _loadUserId().then((_) => loadFirstPage());
  }

  @override
  void onClose() {
    commentTextController.dispose();
    super.onClose();
  }

  int _readAdId() {
    final args = Get.arguments;
    final raw = (args is Map) ? args['adId'] : null;
    if (raw is int) return raw;
    final parsedFromArgs = int.tryParse(raw?.toString() ?? '');
    if (parsedFromArgs != null && parsedFromArgs > 0) return parsedFromArgs;

    // Fallback: read from AdDetailsController if already registered.
    if (Get.isRegistered<AdDetailsController>()) {
      return Get.find<AdDetailsController>().adId;
    }

    return 0;
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_userData');
    if (userJson == null || userJson.isEmpty) return;

    final user = jsonDecode(userJson);
    final rawId = user['id'];
    _userName = (user['name'] ??
            user['username'] ??
            user['full_name'] ??
            user['fullName'])
        ?.toString();

    if (rawId is int) {
      _userId = rawId;
    } else {
      _userId = int.tryParse(rawId?.toString() ?? '');
    }
  }

  Future<void> loadFirstPage() async {
    // Try to resolve adId again in case it wasn't available on init.
    if (adId == 0) {
      adId = _readAdId();
    }

    if (adId == 0) {
      error.value = 'Invalid adId';
      return;
    }

    error.value = '';
    isLoading.value = true;
    page.value = 1;

    try {
      final res = await repository.getComments(
        adId: adId,
        page: 1,
        limit: _limit,
      );

      comments.value = res.items;
      total.value = res.total;
      hasMore.value = comments.length < total.value;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;

    error.value = '';
    isLoading.value = true;

    try {
      final nextPage = page.value + 1;

      final res = await repository.getComments(
        adId: adId,
        page: nextPage,
        limit: _limit,
      );

      comments.addAll(res.items);

      page.value = res.page;
      total.value = res.total;
      hasMore.value = comments.length < total.value;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitComment() async {
    final text = commentTextController.text.trim();
    if (text.isEmpty) return;

    if (_userId == null || _userId == 0) {
      error.value = 'Please login to comment';
      return;
    }

    error.value = '';
    isPosting.value = true;

    try {
      final comment = await repository.createComment(
        adId: adId,
        userId: _userId!,
        text: text,
      );

      comments.insert(
        0,
        CommentEntity(
          id: comment.id,
          text: comment.text.isNotEmpty ? comment.text : text,
          created: comment.created,
          userId: comment.userId,
          userName:
              comment.userName.isNotEmpty
                  ? comment.userName
                  : (_userName ?? 'User'),
        ),
      );
      total.value += 1;

      commentTextController.clear();
      hasMore.value = comments.length < total.value;

      // Sync with server to pick up any backend formatting or defaults.
      await loadFirstPage();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isPosting.value = false;
    }
  }
}
