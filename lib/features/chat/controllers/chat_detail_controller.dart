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
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSending = false.obs;
  final chatTitle = ''.obs;
  final scrollController = ScrollController();

  int? _currentUserId;
  String? _token;
  bool _triedAltSocketPath = false;
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
    socket?.readUserMessages(chatId);
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
      socket?.joinRoom(userId);
      socket?.joinUserRoom(chatId);
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

        if (incoming.senderId == userId && incomingId != null) {
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
            socket?.readUserMessages(chatId);
            return;
          }
        }

        messages.add(incoming);
        _scrollToBottom();
        socket?.readUserMessages(chatId);
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
    if (receiverId == null) return;

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
      senderId: userId,
      receiverId: receiverId,
      message: trimmed,
      type: 'text',
      chatId: chatId,
    );
    socket?.readUserMessages(chatId);
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
          socket?.joinRoom(userId);
          socket?.joinUserRoom(chatId);
          socket?.readUserMessages(chatId);
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
        socket?.joinRoom(userId);
        socket?.joinUserRoom(chatId);
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
}
