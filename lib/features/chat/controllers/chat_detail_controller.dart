import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final isSending = false.obs;
  final chatTitle = ''.obs;
  final scrollController = ScrollController();

  int? _currentUserId;
  String? _token;
  bool _triedAltSocketPath = false;

  @override
  void onInit() {
    super.onInit();
    chatTitle.value = chatName;
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await getUserIdFromPrefs();
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
    await loadMessages();
    await _initSocket();
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    messages.value = await repository.getMessages(
      chatId: chatId,
      userId: userId,
    );

    if (otherUserId == null && messages.isNotEmpty) {
      otherUserId = messages
          .map((m) => m.senderId)
          .firstWhere((id) => id != null && id != userId, orElse: () => null);
    }

    isLoading.value = false;
    _scrollToBottom();
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

    void joinAndRead() {
      socket?.joinUserRoom(userId);
      socket?.readUserMessages(chatId);
    }

    if (socket?.isConnected != true) {
      socket?.connect(query: {'userId': userId}, onConnect: joinAndRead);
    } else {
      joinAndRead();
    }

    socket?.ensureDebugLogging();
    socket?.onConnectError((data) => _retrySocket());
    socket?.onError((data) => _retrySocket());

    socket?.onNewUserMessage((data) {
      final incomingChatId =
          data is Map<String, dynamic>
              ? data['chat_id'] ?? data['chatId']
              : null;
      if (incomingChatId != null && incomingChatId != chatId) return;
      if (data is Map<String, dynamic>) {
        final incoming = MessageModel.fromMap(data, currentUserId: userId);
        final incomingId = incoming.id;
        if (incomingId != null &&
            messages.any((m) => m.id != null && m.id == incomingId)) {
          return;
        }
        messages.add(incoming);
        _scrollToBottom();
      }
    });
    socket?.onNotificationCount((_) {});
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

    final pending = MessageModel(
      text: trimmed,
      isSender: true,
      type: 'text',
      isRead: true,
      createdAt: DateTime.now(),
    );
    messages.add(pending);
    _scrollToBottom();
    _connectSocket(userId);
    socket?.sendUserMessage(
      chatId: chatId,
      message: trimmed,
      receiverId: receiverId,
    );
    socket?.readUserMessages(chatId);

    try {
      final sent = await repository.sendText(
        chatId: chatId,
        userId: userId,
        message: trimmed,
        receiverId: receiverId,
      );
      if (sent != null) {
        _replacePending(pending, sent);
      }
    } catch (e) {
      // ignore: avoid_print
      print('sendMessage failed: $e');
    }
  }

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
    if (socket?.isConnected != true) {
      socket?.connect(
        query: {'userId': userId},
        onConnect: () {
          socket?.joinUserRoom(userId);
          socket?.readUserMessages(chatId);
        },
      );
    } else {
      socket?.joinUserRoom(userId);
    }
  }

  void _retrySocket() {
    if (_triedAltSocketPath) return;
    _triedAltSocketPath = true;
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
    socket?.connect(
      query: {'userId': userId},
      onConnect: () {
        socket?.joinUserRoom(userId);
        socket?.readUserMessages(chatId);
      },
    );
    socket?.ensureDebugLogging();
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

  @override
  void onReady() {
    super.onReady();
    _scrollToBottom();
  }

  @override
  void onClose() {
    scrollController.dispose();
    socket?.disconnect();
    super.onClose();
  }
}
