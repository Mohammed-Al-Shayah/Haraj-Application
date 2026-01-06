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

  SupportDetailController(
    this.repository, {
    required this.chatId,
    required this.chatName,
    this.initialSocket,
  });

  final messages = <SupportMessageEntity>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSending = false.obs;

  final scrollController = ScrollController();

  SocketService? socket;

  int _page = 1;
  int? _currentUserId;
  String? _token;

  bool _triedAltSocketPath = false;
  bool _listenersAttached = false;

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

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels <=
        scrollController.position.minScrollExtent + 120) {
      loadMessages();
      update();
    }
  }

  Future<void> _init() async {
    _currentUserId = await getUserIdFromPrefs();
    await _loadToken();
    await loadMessages(reset: true);
    await _initSocket();
    update();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
    update();
  }

  Future<void> _ensureToken() async {
    if ((_token ?? '').isNotEmpty) return;
    await _loadToken();
    update();
  }

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

    final result = await repository.getMessages(chatId: chatId, page: _page);

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

    _sendReadReceiptsIfNeeded();
    update();
  }

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
      _log('joining support rooms', {'userId': userId, 'chatId': chatId});
      socket?.joinRoom(userId);
      socket?.joinSupportRoom(chatId);
      _sendReadReceiptsIfNeeded();
      onReady?.call();
    }

    if (socket?.isConnected != true) {
      _log('connecting socket', {'userId': userId, 'chatId': chatId});

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

    _log('retrying socket with fallback path');
    socket?.disconnect();

    socket = SocketService(
      socketUrl: ApiEndpoints.supportSocketUrl,
      token: _token,
      path: '/socket.io',
    );

    final userId = _currentUserId;
    if (userId != null) {
      _registerSocketHandlers();
      _connectSocket(userId);
    }
  }

  void sendText(String text) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;

    final trimmed = text.trim();
    if (userId == null || trimmed.isEmpty) return;

    await _ensureToken();

    _log('sendText', {'chatId': chatId, 'userId': userId, 'text': trimmed});

    // Pending
    final pending = SupportMessageModel.pendingText(
      text: trimmed,
      senderId: userId,
      isAdmin: false,
    );

    messages.add(pending);
    _scrollToBottom();

    _sendViaSocket(userId: userId, text: trimmed);
    update();
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

    if (initialSocket == null &&
        (_token ?? '').isNotEmpty &&
        (socket?.token == null || (socket?.token ?? '').isEmpty)) {
      socket?.disconnect();
      socket = SocketService(
        socketUrl: ApiEndpoints.supportSocketUrl,
        token: _token,
        path: '/haraj/socket.io',
      );
      _listenersAttached = false;
    }

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

        _log('emitting sendSupportMessage', payload);

        socket?.sendSupportMessage(
          userId: userId,
          message: payload,
          chatId: chatId,
        );

        _sendReadReceiptsIfNeeded();
      },
    );
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

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
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

    if (data['sender_id'] != null && result['sender_id'] == null) {
      result['sender_id'] = data['sender_id'];
    }
    if (data['senderId'] != null && result['senderId'] == null) {
      result['senderId'] = data['senderId'];
    }
    if (data['is_admin'] != null && result['is_admin'] == null) {
      result['is_admin'] = data['is_admin'];
    }
    if (data['isAdmin'] != null && result['isAdmin'] == null) {
      result['isAdmin'] = data['isAdmin'];
    }
    if (data['created_at'] != null && result['created_at'] == null) {
      result['created_at'] = data['created_at'];
    }
    if (data['created'] != null && result['created'] == null) {
      result['created'] = data['created'];
    }

    return result;
  }

  void _registerSocketHandlers() {
    if (socket == null || _listenersAttached) return;
    _listenersAttached = true;

    socket?.ensureDebugLogging(logger: _log);

    socket?.onConnectError((data) {
      _log('socket connect_error', data);
      _retrySocket();
    });

    socket?.onError((data) {
      _log('socket error', data);
      _retrySocket();
    });

    socket?.onNewSupportMessage((data) {
      final payload =
          data is Map<String, dynamic> ? Map<String, dynamic>.from(data) : null;
      if (payload == null) return;

      final messageData = _extractSupportMessagePayload(payload);
      final incomingChatId = _parseInt(
        messageData['support_chat_id'] ??
            messageData['supportChatId'] ??
            messageData['chat_id'] ??
            messageData['chatId'] ??
            payload['support_chat_id'] ??
            payload['supportChatId'] ??
            payload['chat_id'] ??
            payload['chatId'],
      );

      if (incomingChatId != null && incomingChatId != chatId) return;

      if (messageData.isNotEmpty) {
        final message = SupportMessageModel.fromMap(messageData);
        final incomingId = message.id;
        _log('newSupportMessage', data);

        if (incomingId != null &&
            messages.any((m) => m.id != null && m.id == incomingId)) {
          return;
        }

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
    });
    socket?.onSupportMessagesRead((data) {
      if (data is Map<String, dynamic>) {
        final ids = data['messageIds'] ?? data['ids'];
        if (ids is List) {
          final readIds =
              ids
                  .map((e) {
                    if (e is num) return e.toInt();
                    return int.tryParse(e.toString());
                  })
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
                      isRead:
                          m.isRead || (m.id != null && readIds.contains(m.id)),
                      createdAt: m.createdAt,
                      mediaUrl: m.mediaUrl,
                    ),
                  )
                  .toList();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _scrollToBottom();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    socket?.disconnect();
    super.onClose();
  }
}
