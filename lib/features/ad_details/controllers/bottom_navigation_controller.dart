import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/utils/chat_cache.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_controller.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';

class BottomNavigationController extends GetxController {
  final AdDetailsController adDetailsController;
  final ApiClient apiClient;

  BottomNavigationController({
    required this.adDetailsController,
    ApiClient? apiClient,
  }) : apiClient = apiClient ?? ApiClient(client: Dio());

  Future<void> openChatWithOwner() async {
    final ad = adDetailsController.ad.value;
    final ownerId = ad?.ownerId;
    final adId = ad?.id ?? adDetailsController.adId;
    final ownerName =
        (ad?.ownerName ?? '').trim().isEmpty ? 'Owner' : ad!.ownerName!.trim();

    if (ownerId == null) {
      AppSnack.error('Error', 'Owner info is not available.');
      return;
    }

    final currentUserId = await getUserIdFromPrefs();
    if (currentUserId == null) {
      AppSnack.error('Error', 'Please log in to start a chat.');
      return;
    }

    final resolvedCache = await _resolveExistingChat(ownerId);
    if (resolvedCache != null) {
      _navigateToChat(resolvedCache, ownerName, ownerId);
      return;
    }

    try {
      var chatData = await _findExistingChat(
        apiClient: apiClient,
        currentUserId: currentUserId,
        ownerId: ownerId,
        fallbackName: ownerName,
      );

      chatData ??= await _createChatWithOwner(
        apiClient: apiClient,
        currentUserId: currentUserId,
        ownerId: ownerId,
        fallbackName: ownerName,
        adId: adId,
      );

      final cacheFuture =
          chatData != null
              ? ChatCache.setChatIdForUser(ownerId, chatData.chatId)
              : Future<void>.value();
      unawaited(cacheFuture);

      final launchData =
          chatData ??
          _ChatLaunchData(
            chatId: adId > 0 ? adId : ownerId,
            chatTitle: ownerName,
            otherUserId: ownerId,
          );

      _navigateToChat(
        launchData.chatId,
        launchData.chatTitle,
        launchData.otherUserId,
      );
    } catch (_) {
      AppSnack.error('Error', 'Failed to open chat.');
    }
  }

  Future<int?> _resolveExistingChat(int ownerId) async {
    final fromController = _chatIdFromController(ownerId);
    if (fromController != null) {
      unawaited(ChatCache.setChatIdForUser(ownerId, fromController));
      return fromController;
    }

    final cached = await ChatCache.getChatIdForUser(ownerId);
    if (cached != null && cached > 0) {
      return cached;
    }
    return null;
  }

  int? _chatIdFromController(int ownerId) {
    if (!Get.isRegistered<ChatController>()) return null;
    final controller = Get.find<ChatController>();
    for (final chat in controller.chats) {
      if (chat.otherUserId == ownerId && chat.id != null) {
        return chat.id;
      }
    }
    return null;
  }

  Future<_ChatLaunchData?> _findExistingChat({
    required int currentUserId,
    required int ownerId,
    required String fallbackName,
    ApiClient? apiClient,
  }) async {
    final api = apiClient ?? this.apiClient;
    final attempts = <dynamic>[
      await api.get(
        ApiEndpoints.chatList,
        queryParams: {'page': 1, 'limit': 50},
      ),
      await api.get(
        ApiEndpoints.chatList,
        queryParams: {
          'page': 1,
          'limit': 50,
          'userId': currentUserId,
          'user_id': currentUserId,
        },
      ),
    ];

    for (final res in attempts) {
      final parsed = _parseChatResponse(res, ownerId, fallbackName);
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<_ChatLaunchData?> _createChatWithOwner({
    required int currentUserId,
    required int ownerId,
    required String fallbackName,
    required int adId,
    ApiClient? apiClient,
  }) async {
    final api = apiClient ?? this.apiClient;
    final attempts = <_ChatCreateAttempt>[];
    if (adId > 0) {
      attempts.add(_ChatCreateAttempt(data: {'adId': adId}));
      attempts.add(_ChatCreateAttempt(data: {'ad_id': adId}));
      attempts.add(
        _ChatCreateAttempt(data: <String, dynamic>{}, query: {'adId': adId}),
      );
      attempts.add(
        _ChatCreateAttempt(data: <String, dynamic>{}, query: {'ad_id': adId}),
      );
    }
    attempts.add(_ChatCreateAttempt(data: <String, dynamic>{}));

    for (final attempt in attempts) {
      try {
        final res = await api.post(
          ApiEndpoints.chats,
          data: attempt.data,
          queryParameters: attempt.query,
        );
        final created = _parseChatResponse(res, ownerId, fallbackName);
        if (created != null) return created;
      } catch (_) {}
    }

    final found = await _findExistingChat(
      apiClient: api,
      currentUserId: currentUserId,
      ownerId: ownerId,
      fallbackName: fallbackName,
    );
    if (found != null) return found;

    return _findExistingChat(
      apiClient: api,
      currentUserId: currentUserId,
      ownerId: ownerId,
      fallbackName: fallbackName,
    );
  }

  void _navigateToChat(int chatId, String chatTitle, int? otherUserId) {
    Get.toNamed(
      Routes.chatDetailsScreen,
      arguments: {
        'chatId': chatId,
        'chatName': chatTitle,
        'otherUserId': otherUserId,
      },
    );
  }

  _ChatLaunchData? _parseChatResponse(
    dynamic res,
    int ownerId,
    String fallbackName,
  ) {
    final mapCandidate = _extractMap(res);
    if (mapCandidate != null) {
      final parsed = _parseChat(mapCandidate, ownerId, fallbackName);
      if (parsed != null) return parsed;
    }

    final data = _extractList(res);
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final parsed = _parseChat(item, ownerId, fallbackName);
      if (parsed != null) return parsed;
    }
    return null;
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    if (res is List) return res;
    return const [];
  }

  Map<String, dynamic>? _extractMap(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is Map<String, dynamic>) return data;
      final result = res['result'];
      if (result is Map<String, dynamic>) return result;
      final chat = res['chat'];
      if (chat is Map<String, dynamic>) return chat;
      if (res['id'] != null ||
          res['chat_id'] != null ||
          res['chatId'] != null) {
        return res;
      }
    }
    return null;
  }

  _ChatLaunchData? _parseChat(
    Map<String, dynamic> item,
    int ownerId,
    String fallbackName,
  ) {
    final members = item['members'];
    int? chatId;
    String chatTitle = fallbackName;
    int otherUserId = ownerId;

    if (members is List) {
      for (final member in members) {
        if (member is! Map) continue;
        final uid = _toInt(member['user_id'] ?? member['userId']);
        if (uid == ownerId) {
          otherUserId = uid ?? ownerId;
          chatId = _toInt(item['id'] ?? item['chat_id'] ?? item['chatId']);
          final user = member['users'];
          if (user is Map && (user['name']?.toString().isNotEmpty ?? false)) {
            chatTitle = user['name'].toString();
          }
          break;
        }
      }
    }

    chatId ??= _toInt(item['id'] ?? item['chat_id'] ?? item['chatId']);
    final title = _extractUserName(item) ?? chatTitle;
    final other =
        _toInt(
          item['other_user_id'] ??
              item['receiver_id'] ??
              item['receiverId'] ??
              item['user_id'] ??
              item['userId'],
        ) ??
        _toInt(item['owner_id'] ?? item['ownerId']) ??
        otherUserId;

    if (chatId == null) return null;
    return _ChatLaunchData(
      chatId: chatId,
      chatTitle: title,
      otherUserId: other,
    );
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _extractUserName(Map<String, dynamic> data) {
    final user = data['user'] ?? data['owner'] ?? data['receiver'];
    if (user is Map) {
      final name = user['name'] ?? user['user_name'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }
    final directName = data['name'] ?? data['user_name'];
    if (directName != null && directName.toString().trim().isNotEmpty) {
      return directName.toString();
    }
    return null;
  }
}

class _ChatLaunchData {
  final int chatId;
  final String chatTitle;
  final int otherUserId;

  _ChatLaunchData({
    required this.chatId,
    required this.chatTitle,
    required this.otherUserId,
  });
}

class _ChatCreateAttempt {
  final Map<String, dynamic> data;
  final Map<String, dynamic>? query;

  _ChatCreateAttempt({required this.data, this.query});
}
