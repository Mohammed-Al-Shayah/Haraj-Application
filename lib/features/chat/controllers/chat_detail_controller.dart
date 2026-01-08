import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_controller.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/chat_detail_repository.dart';

class ChatDetailController extends GetxController {
  final ChatDetailRepository repository;
  final int chatId;
  final SocketService? initialSocket;
  SocketService? socket;
  final String chatName;
  int? otherUserId;

  ChatDetailController(
    this.repository, {
    required this.chatId,
    required this.chatName,
    this.initialSocket,
    this.otherUserId,
  });

  final messages = <MessageEntity>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSending = false.obs;
  final chatTitle = ''.obs;
  final scrollController = ScrollController();

  int? _currentUserId;
  String? _token;
  bool _triedAltSocketPath = false;
  bool _listenersAttached = false;
  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _pendingSyncAfterLoad = false;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    chatTitle.value = chatName;
    scrollController.addListener(_onScroll);
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await getUserIdFromPrefs();
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
    await loadMessages(reset: true);
    await _initSocket();
    _startSyncTimer();
  }

  Future<void> loadMessages({bool reset = false}) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) {
      isLoading.value = false;
      isLoadingMore.value = false;
      return;
    }

    if (reset) {
      _page = 1;
      hasMore.value = true;
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
    }

    if (reset) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    double? distanceFromBottom;
    if (!reset && scrollController.hasClients) {
      final pos = scrollController.position;
      distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    }

    final result = await repository.getMessages(
      chatId: chatId,
      currentUserId: userId,
      otherUserId: otherUserId,
      page: _page,
      limit: _pageSize,
    );

    if (otherUserId == null && result.items.isNotEmpty) {
      otherUserId = result.items
          .map((m) => m.senderId)
          .firstWhere((id) => id != null && id != userId, orElse: () => null);
    }

    if (reset) {
      messages.assignAll(result.items);
      _scrollToBottom();
    } else {
      messages.insertAll(0, result.items);
      if (distanceFromBottom != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scrollController.hasClients) return;
          final max = scrollController.position.maxScrollExtent;
          final target = (max - distanceFromBottom!).clamp(
            scrollController.position.minScrollExtent,
            scrollController.position.maxScrollExtent,
          );
          scrollController.jumpTo(target);
        });
      }
    }

    hasMore.value = result.hasMore;
    _page = result.page + 1;

    isLoading.value = false;
    isLoadingMore.value = false;
    _markRead();
    if (reset) {
      _clearUnreadInList();
    }
    update();
    if (_pendingSyncAfterLoad && !isLoading.value && !isLoadingMore.value) {
      _pendingSyncAfterLoad = false;
      _syncLatest();
    }
  }

  Future<void> _initSocket() async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) return;

    final uri = Uri.parse(ApiEndpoints.baseUrl);
    final baseSocketUrl = '${uri.scheme}://${uri.host}';
    socket =
        initialSocket ??
        SocketService(
          socketUrl: baseSocketUrl,
          token: _token,
          path: '/haraj/socket.io',
        );
    _listenersAttached = false;
    _registerSocketHandlers();

    void joinAndRead() {
      socket?.joinRoom(userId);
      socket?.joinUserRoom(chatId);
      _markRead();
    }

    final query = <String, dynamic>{
      'userId': userId,
      if ((_token ?? '').isNotEmpty) 'token': _token,
    };
    if (socket?.isConnected != true) {
      socket?.connect(query: query, onConnect: joinAndRead);
    } else {
      joinAndRead();
    }

    update();
  }

  void _registerSocketHandlers() {
    if (socket == null || _listenersAttached) return;
    _listenersAttached = true;

    socket?.ensureDebugLogging();
    socket?.onConnectError((data) => _retrySocket());
    socket?.onError((data) => _retrySocket());
    socket?.onNewUserMessage(_handleIncomingMessage);
    socket?.onNotificationCount((_) {});
  }

  void _handleIncomingMessage(dynamic data) {
    final payload = _coercePayload(data);
    if (payload == null) return;
    final messageData = _extractMessagePayload(payload);
    final incomingChatId = _parseInt(
      messageData['chat_id'] ??
          messageData['chatId'] ??
          payload['chat_id'] ??
          payload['chatId'],
    );
    if (incomingChatId != null && incomingChatId != chatId) return;
    if (messageData.isEmpty) return;

    final userId = _currentUserId;
    final incoming = MessageModel.fromMap(messageData, currentUserId: userId);
    final incomingId = incoming.id;
    if (incomingId != null &&
        messages.any((m) => m.id != null && m.id == incomingId)) {
      return;
    }

    if (userId != null && incoming.senderId == userId && incomingId != null) {
      final pendingIndex = messages.indexWhere(
        (m) =>
            m.id == null &&
            m.senderId == userId &&
            m.text == incoming.text &&
            m.type == incoming.type,
      );
      if (pendingIndex != -1) {
        messages[pendingIndex] = incoming;
        messages.refresh();
        _scrollToBottom();
        _markRead();
        return;
      }
    }

    messages.add(incoming);
    _scrollToBottom();
    _markRead();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _syncLatest(),
    );
  }

  Future<void> _syncLatest() async {
    if (_isSyncing) return;
    if (isLoading.value || isLoadingMore.value) {
      _pendingSyncAfterLoad = true;
      return;
    }
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) return;

    _isSyncing = true;
    try {
      final result = await repository.getMessages(
        chatId: chatId,
        currentUserId: userId,
        otherUserId: otherUserId,
        page: 1,
        limit: _pageSize,
      );
      if (otherUserId == null && result.items.isNotEmpty) {
        otherUserId = result.items
            .map((m) => m.senderId)
            .firstWhere((id) => id != null && id != userId, orElse: () => null);
      }
      _mergeLatest(result.items);
    } finally {
      _isSyncing = false;
    }
  }

  void _mergeLatest(List<MessageEntity> latest) {
    if (latest.isEmpty) return;
    final ordered = _normalizeLatestOrder(latest);
    final existingIds =
        messages.where((m) => m.id != null).map((m) => m.id!).toSet();

    final userId = _currentUserId;
    var changed = false;

    for (final incoming in ordered) {
      final incomingId = incoming.id;
      if (incomingId != null && existingIds.contains(incomingId)) {
        continue;
      }

      if (userId != null && incoming.senderId == userId && incomingId != null) {
        final pendingIndex = messages.indexWhere(
          (m) =>
              m.id == null &&
              m.senderId == userId &&
              m.text == incoming.text &&
              m.type == incoming.type,
        );
        if (pendingIndex != -1) {
          messages[pendingIndex] = incoming;
          changed = true;
          continue;
        }
      }

      messages.add(incoming);
      if (incomingId != null) {
        existingIds.add(incomingId);
      }
      changed = true;
    }

    if (changed) {
      messages.refresh();
      _scrollToBottom();
      _markRead();
    }
  }

  List<MessageEntity> _normalizeLatestOrder(List<MessageEntity> latest) {
    if (latest.length < 2) return latest;
    final first = latest.first.createdAt;
    final last = latest.last.createdAt;
    if (first != null && last != null && first.isAfter(last)) {
      return latest.reversed.toList();
    }
    return latest;
  }

  Future<void> sendMessage(String text) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;

    final trimmed = text.trim();
    if (trimmed.isEmpty || userId == null) return;

    final receiverId =
        otherUserId ??
        messages
            .map((m) => m.senderId)
            .firstWhere((id) => id != null && id != userId, orElse: () => null);
    otherUserId = receiverId ?? otherUserId;
    if (receiverId == null) return;

    final pending = MessageModel(
      id: null,
      senderId: userId,
      text: trimmed,
      isSender: true,
      type: 'text',
      isRead: true,
      createdAt: DateTime.now(),
    );

    messages.add(pending);
    _scrollToBottom();

    _connectSocket(userId);

    // ✅ no chatId
    socket?.sendUserMessage(
      senderId: userId,
      receiverId: receiverId,
      message: trimmed,
      type: 'text',
    );

    _markRead();
  }
  // Future<void> sendMessage(String text) async {
  //   final userId = _currentUserId ?? await getUserIdFromPrefs();
  //   _currentUserId = userId;
  //   final trimmed = text.trim();
  //   if (trimmed.isEmpty || userId == null) return;

  //   final receiverId =
  //       otherUserId ??
  //       messages
  //           .map((m) => m.senderId)
  //           .firstWhere((id) => id != null && id != userId, orElse: () => null);
  //   otherUserId = receiverId ?? otherUserId;
  //   if (receiverId == null) return;

  //   final pending = MessageModel(
  //     text: trimmed,
  //     isSender: true,
  //     type: 'text',
  //     isRead: true,
  //     createdAt: DateTime.now(),
  //   );
  //   messages.add(pending);
  //   _scrollToBottom();
  //   _connectSocket(userId);
  //   socket?.sendUserMessage(
  //     senderId: userId,
  //     receiverId: receiverId,
  //     message: trimmed,
  //     type: 'text',
  //     chatId: chatId,
  //   );
  //   _markRead();
  // }

  Future<void> sendMedia({
    required String filePath,
    required String type,
  }) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null || filePath.isEmpty) return;

    final receiverId =
        otherUserId ??
        messages
            .map((m) => m.senderId)
            .firstWhere((id) => id != null && id != userId, orElse: () => null);
    otherUserId = receiverId ?? otherUserId;

    isSending.value = true;
    final pending = MessageModel(
      text: '',
      isSender: true,
      type: type,
      mediaUrl: null,
      localFilePath: filePath,
      createdAt: DateTime.now(),
    );
    messages.add(pending);
    _scrollToBottom();
    _connectSocket(userId);

    try {
      final uploaded = await repository.uploadMedia(
        chatId: chatId,
        userId: userId,
        type: type,
        filePath: filePath,
        receiverId: receiverId,
      );
      if (uploaded != null) {
        _replacePending(pending, uploaded);
      }
    } catch (e) {
      // ignore: avoid_print
      print('sendMedia failed: $e');
    } finally {
      isSending.value = false;
    }
  }

  void _replacePending(MessageEntity pending, MessageEntity replacement) {
    final index = messages.indexOf(pending);
    if (index == -1) {
      messages.add(replacement);
    } else {
      messages[index] = replacement;
    }
    messages.refresh();
    _scrollToBottom();
  }

  void _connectSocket(int userId) {
    if (socket == null) {
      _initSocket();
      return;
    }
    _registerSocketHandlers();
    if (socket?.isConnected != true) {
      final query = <String, dynamic>{
        'userId': userId,
        if ((_token ?? '').isNotEmpty) 'token': _token,
      };
      socket?.connect(
        query: query,
        onConnect: () {
          socket?.joinRoom(userId);
          socket?.joinUserRoom(chatId);
          _markRead();
        },
      );
    } else {
      socket?.joinRoom(userId);
      socket?.joinUserRoom(chatId);
    }
  }

  void _retrySocket() {
    if (_triedAltSocketPath) return;
    _triedAltSocketPath = true;
    _listenersAttached = false;
    socket?.disconnect();
    socket = SocketService(
      socketUrl: Uri.parse(
        ApiEndpoints.baseUrl,
      ).replace(path: '').toString().replaceFirst(RegExp(r'/+$'), ''),
      token: _token,
      path: '/socket.io',
    );
    final userId = _currentUserId;
    if (userId == null) return;
    _registerSocketHandlers();
    final query = <String, dynamic>{
      'userId': userId,
      if ((_token ?? '').isNotEmpty) 'token': _token,
    };
    socket?.connect(
      query: query,
      onConnect: () {
        socket?.joinRoom(userId);
        socket?.joinUserRoom(chatId);
        _markRead();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearUnreadInList() {
    if (!Get.isRegistered<ChatController>()) return;
    Get.find<ChatController>().clearUnread(chatId);
  }

  void _markRead() {
    socket?.readUserMessages(
      chatId,
      userId: _currentUserId,
      receiverId: otherUserId,
    );
    if (_currentUserId != null) {
      socket?.countChatNotifications(_currentUserId!);
    }
    _updateReadMarker();
  }

  void _updateReadMarker() {
    if (!Get.isRegistered<ChatController>()) return;
    if (messages.isEmpty) return;

    MessageEntity? latest;
    for (final msg in messages) {
      final createdAt = msg.createdAt;
      if (createdAt == null) continue;
      if (latest == null || createdAt.isAfter(latest.createdAt!)) {
        latest = msg;
      }
    }
    latest ??= messages.last;

    final lastMessage = latest.text;
    final lastTime = latest.createdAt?.toIso8601String() ?? '';
    Get.find<ChatController>().markChatRead(
      chatId,
      lastMessage: lastMessage,
      lastTime: lastTime,
    );
  }

  @override
  void onReady() {
    super.onReady();
    _scrollToBottom();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    socket?.disconnect();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        isLoading.value ||
        isLoadingMore.value) {
      return;
    }
    if (scrollController.position.pixels <=
        scrollController.position.minScrollExtent + 120) {
      loadMessages();
    }
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic>? _coercePayload(dynamic data) {
    dynamic current = data;
    if (current is String) {
      try {
        current = jsonDecode(current);
      } catch (_) {
        return null;
      }
    }

    if (current is List) {
      for (final item in current.reversed) {
        if (item is Map<String, dynamic>) {
          return Map<String, dynamic>.from(item);
        }
        if (item is Map) {
          return item.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    }

    if (current is Map<String, dynamic>) {
      return Map<String, dynamic>.from(current);
    }
    if (current is Map) {
      return current.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Map<String, dynamic> _extractMessagePayload(Map<String, dynamic> data) {
    int? chatIdValue = _parseInt(data['chat_id'] ?? data['chatId']);
    if (chatIdValue == null) {
      final chat = data['chat'];
      if (chat is Map) {
        chatIdValue = _parseInt(chat['id'] ?? chat['chat_id']);
      }
    }

    final rawNested = data['message'] ?? data['data'] ?? data['payload'];
    final nested =
        rawNested is Map<String, dynamic>
            ? Map<String, dynamic>.from(rawNested)
            : null;
    final result = nested ?? Map<String, dynamic>.from(data);

    if (chatIdValue != null) {
      result.putIfAbsent('chat_id', () => chatIdValue);
      result.putIfAbsent('chatId', () => chatIdValue);
    }

    if (data['sender_id'] != null && result['sender_id'] == null) {
      result['sender_id'] = data['sender_id'];
    }
    if (data['senderId'] != null && result['senderId'] == null) {
      result['senderId'] = data['senderId'];
    }
    if (data['created_at'] != null && result['created_at'] == null) {
      result['created_at'] = data['created_at'];
    }
    if (data['created'] != null && result['created'] == null) {
      result['created'] = data['created'];
    }

    return result;
  }
}
