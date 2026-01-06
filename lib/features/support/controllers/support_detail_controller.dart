import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/data/models/support_message_model.dart';
import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportDetailController extends GetxController {
  final SupportRepository repository;
  final int chatId;
  final String chatName;
  final SocketService? initialSocket;

  final int? initialUserId;

  SupportDetailController(
    this.repository,
    this.initialSocket, {
    required this.chatId,
    required this.chatName,
    this.initialUserId,
  });


  final messages = <SupportMessageEntity>[].obs;

  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSending = false.obs;

  final scrollController = ScrollController();

  SocketService? socket;

  int _page = 1;
  static const int _pageSize = 20;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;
  String? _token;

  bool _triedAltSocketPath = false;
  bool _listenersAttached = false;
  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _pendingSyncAfterLoad = false;

  void _log(String message, [dynamic data]) {
    // ignore: avoid_print
    print('[SupportDetail] $message${data != null ? ' => $data' : ''}');
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _init();
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
    if (!scrollController.hasClients) return;
    if (isLoading.value || isLoadingMore.value) return;

    if (scrollController.position.pixels <=
        scrollController.position.minScrollExtent + 120) {
      loadMessages();
    }
  }

  Future<void> _init() async {
    _currentUserId = initialUserId ?? await getUserIdFromPrefs();
    await _loadToken();
    await loadMessages(reset: true);
    await _initSocket();
    _startSyncTimer();
    update();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
  }

  Future<void> _ensureToken() async {
    if ((_token ?? '').isNotEmpty) return;
    await _loadToken();
  }

  // ---------------------------
  Future<void> loadMessages({bool reset = false}) async {
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
      page: _page,
      limit: _pageSize,
    );

    if (reset) {
      messages.assignAll(result.items);
      _scrollToBottom();
    } else {
      messages.insertAll(0, result.items);
      _restoreScroll(distanceFromBottom);
    }

    hasMore.value = result.hasMore;
    _page = result.page + 1;

    isLoading.value = false;
    isLoadingMore.value = false;

    _sendReadReceiptsIfNeeded();
    update();
    if (_pendingSyncAfterLoad && !isLoading.value && !isLoadingMore.value) {
      _pendingSyncAfterLoad = false;
      _syncLatest();
    }
  }

  // ---------------------------
  Future<void> _initSocket() async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) return;

    _triedAltSocketPath = false;
    _listenersAttached = false;

    socket =
        initialSocket ??
        SocketService(
          socketUrl: ApiEndpoints.supportSocketUrl,
          token: _token,
          path: '/haraj/socket.io',
        );

    _registerSocketHandlers();
    _connectSocket(userId);
  }

  void _connectSocket(int userId, {VoidCallback? onReady}) {
    if (socket == null) return;

    void joinRooms() {
      _log('join support rooms', {'userId': userId, 'chatId': chatId});
      socket?.joinRoom(userId);
      socket?.joinSupportRoom(chatId);
      _sendReadReceiptsIfNeeded();
      onReady?.call();
    }

    if (socket?.isConnected != true) {
      final query = <String, dynamic>{
        'userId': userId,
        if ((_token ?? '').isNotEmpty) 'token': _token,
      };
      socket?.connect(query: query, onConnect: joinRooms);
    } else {
      joinRooms();
    }
  }

  void _retrySocket() {
    if (_triedAltSocketPath) return;
    _triedAltSocketPath = true;

    _listenersAttached = false;
    _log('retry socket with fallback path');

    socket?.disconnect();
    socket = SocketService(
      socketUrl: ApiEndpoints.supportSocketUrl,
      token: _token,
      path: '/socket.io',
    );

    final userId = _currentUserId;
    if (userId == null) return;

    _registerSocketHandlers();
    _connectSocket(userId);
  }

  void _registerSocketHandlers() {
    if (socket == null || _listenersAttached) return;
    _listenersAttached = true;

    socket?.ensureDebugLogging(logger: (e, d) => _log(e, d));

    socket?.onConnectError((data) {
      _log('connect_error', data);
      _retrySocket();
    });

    socket?.onError((data) {
      _log('error', data);
      _retrySocket();
    });

    socket?.onNewSupportMessage(_handleIncomingSupportMessage);

    socket?.onSupportMessagesRead(_handleSupportMessagesRead);
  }

  // ---------------------------
  void sendText(String text) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;

    final trimmed = text.trim();
    if (userId == null || trimmed.isEmpty) return;

    await _ensureToken();

    // UI pending
    final pending = SupportMessageModel.pendingText(
      text: trimmed,
      senderId: userId,
      isAdmin: false,
    );

    messages.add(pending);
    _scrollToBottom();

    _sendViaSocket(userId: userId, text: trimmed);
  }

  Future<void> uploadMedia({
    required String filePath,
    required String type,
    bool isAdmin = false,
  }) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) return;

    isSending.value = true;
    try {
      final uploaded = await repository.uploadMedia(
        chatId: chatId,
        userId: userId,
        type: type,
        filePath: filePath,
        isAdmin: isAdmin,
      );

      if (uploaded != null) {
        messages.add(uploaded);
        _scrollToBottom();
        _sendReadReceiptsIfNeeded();
      }
    } finally {
      isSending.value = false;
    }
    update();
  }

  void _sendViaSocket({required int userId, required String text}) {
    socket ??=
        initialSocket ??
        SocketService(
          socketUrl: ApiEndpoints.supportSocketUrl,
          token: _token,
          path: '/haraj/socket.io',
        );

    _registerSocketHandlers();

    _connectSocket(
      userId,
      onReady: () {
        final payload = <String, dynamic>{
          'type': 'text',
          'message': text,
          'sender_id': userId,
          'is_admin': false,
        };

        _log('emit sendSupportMessage', payload);

        socket?.sendSupportMessage(
          userId: userId,
          message: payload,
          chatId: chatId,
        );

        _sendReadReceiptsIfNeeded();
      },
    );
  }

  // ---------------------------
  void _handleIncomingSupportMessage(dynamic data) {
    final payload = _coerceToMap(data);
    if (payload == null) return;

    final messageData = _extractSupportMessagePayload(payload);
    if (messageData.isEmpty) return;

    final incomingChatId = _parseInt(
      messageData['support_chat_id'] ??
          messageData['supportChatId'] ??
          messageData['chat_id'] ??
          messageData['chatId'],
    );

    if (incomingChatId != null && incomingChatId != chatId) return;

    final message = SupportMessageModel.fromMap(messageData);
    _log('newSupportMessage', messageData);

    if (message.id != null && messages.any((m) => m.id == message.id)) return;

    // replace pending
    final currentUserId = _currentUserId;
    if (currentUserId != null &&
        message.senderId == currentUserId &&
        message.id != null) {
      final pendingIndex = messages.indexWhere(
        (m) =>
            m.id == null &&
            m.senderId == currentUserId &&
            m.message == message.message &&
            m.type == message.type,
      );
      if (pendingIndex != -1) {
        messages[pendingIndex] = message;
        messages.refresh();
        _scrollToBottom();
        _sendReadReceiptsIfNeeded();
        return;
      }
    }

    messages.add(message);
    _scrollToBottom();
    _sendReadReceiptsIfNeeded();
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
        page: 1,
        limit: _pageSize,
      );
      _mergeLatest(result.items);
    } finally {
      _isSyncing = false;
    }
  }

  void _mergeLatest(List<SupportMessageEntity> latest) {
    if (latest.isEmpty) return;
    final ordered = _normalizeLatestOrder(latest);
    final existingIds =
        messages
            .where((m) => m.id != null)
            .map((m) => m.id!)
            .toSet();

    final userId = _currentUserId;
    var changed = false;

    for (final incoming in ordered) {
      final incomingId = incoming.id;
      if (incomingId != null && existingIds.contains(incomingId)) {
        continue;
      }

      if (userId != null &&
          incoming.senderId == userId &&
          incomingId != null) {
        final pendingIndex = messages.indexWhere(
          (m) =>
              m.id == null &&
              m.senderId == userId &&
              m.message == incoming.message &&
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
      _sendReadReceiptsIfNeeded();
    }
  }

  List<SupportMessageEntity> _normalizeLatestOrder(
    List<SupportMessageEntity> latest,
  ) {
    if (latest.length < 2) return latest;
    final first = latest.first.createdAt;
    final last = latest.last.createdAt;
    if (first != null && last != null && first.isAfter(last)) {
      return latest.reversed.toList();
    }
    return latest;
  }

  void _handleSupportMessagesRead(dynamic data) {
    if (data is! Map) return;
    final map = data.map((k, v) => MapEntry(k.toString(), v));

    final ids = map['messageIds'] ?? map['ids'];
    if (ids is! List) return;

    final readIds =
        ids
            .map((e) => e is num ? e.toInt() : int.tryParse(e.toString()))
            .whereType<int>()
            .toSet();

    messages.value =
        messages
            .map(
              (m) => SupportMessageModel(
                id: m.id,
                message: m.message,
                type: m.type,
                senderId: m.senderId,
                isAdmin: m.isAdmin,
                isRead: m.isRead || (m.id != null && readIds.contains(m.id)),
                createdAt: m.createdAt,
                mediaUrl: m.mediaUrl,
              ),
            )
            .toList();
  }

  void _sendReadReceiptsIfNeeded() {
    final userId = _currentUserId;
    if (userId == null) return;

    final unreadIds =
        messages
            .where(
              (m) =>
                  m.id != null &&
                  !m.isRead &&
                  (m.senderId == null || m.senderId != userId),
            )
            .map((m) => m.id!)
            .toList();

    if (unreadIds.isEmpty) return;

    socket?.sendSupportReadReceipt(chatId, unreadIds);
  }

  bool isFromCurrentUser(SupportMessageEntity msg) {
    final id = _currentUserId;
    if (id == null) return !msg.isAdmin;
    return msg.senderId == id;
  }

  // ---------------------------
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _restoreScroll(double? distanceFromBottom) {
    if (distanceFromBottom == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      final target = (max - distanceFromBottom).clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(target);
    });
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic>? _coerceToMap(dynamic data) {
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
        final map = _coerceToMap(item);
        if (map != null) return map;
      }
      return null;
    }

    if (current is Map<String, dynamic>) {
      return Map<String, dynamic>.from(current);
    }
    if (current is Map) return current.map((k, v) => MapEntry(k.toString(), v));

    return null;
  }

  Map<String, dynamic> _extractSupportMessagePayload(
    Map<String, dynamic> data,
  ) {
    int? chatIdValue = _parseInt(
      data['support_chat_id'] ??
          data['supportChatId'] ??
          data['chat_id'] ??
          data['chatId'],
    );

    if (chatIdValue == null) {
      final chat = data['chat'];
      if (chat is Map) {
        chatIdValue = _parseInt(
          chat['id'] ?? chat['support_chat_id'] ?? chat['chat_id'],
        );
      }
    }

    final rawNested = data['message'] ?? data['data'] ?? data['payload'];
    final nested =
        rawNested is Map<String, dynamic>
            ? Map<String, dynamic>.from(rawNested)
            : null;
    final result = nested ?? Map<String, dynamic>.from(data);

    if (chatIdValue != null) {
      result.putIfAbsent('support_chat_id', () => chatIdValue);
      result.putIfAbsent('supportChatId', () => chatIdValue);
      result.putIfAbsent('chat_id', () => chatIdValue);
      result.putIfAbsent('chatId', () => chatIdValue);
    }

    // normalize common fields
    for (final key in [
      'sender_id',
      'senderId',
      'is_admin',
      'isAdmin',
      'created_at',
      'created',
    ]) {
      if (data[key] != null && result[key] == null) {
        result[key] = data[key];
      }
    }

    return result;
  }
}
