import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository repository;

  ChatController(this.repository);

  final chats = <ChatEntity>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final searchController = TextEditingController();
  final unreadTotal = 0.obs;

  int _page = 1;
  Timer? _debounce;
  SocketService? socket;
  String? _token;
  String? _baseSocketUrl;
  int? _currentUserId;
  bool _listenersAttached = false;
  bool _triedAltSocketPath = false;
  bool _isSocketInitializing = false;
  final Map<int, _ReadMarker> _readMarkers = {};
  bool _markersLoaded = false;
  bool _markersDirty = false;
  int? _markersUserId;

  @override
  void onInit() {
    super.onInit();
    loadChats(reset: true);
    _initSocket();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    socket?.disconnect();
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

    final userId = await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) {
      chats.clear();
      isLoading.value = false;
      isLoadingMore.value = false;
      return;
    }

    await _loadMarkersIfNeeded(userId);
    _initSocket();

    final search = searchController.text.trim();

    final result = await repository.getChats(
      userId: userId,
      page: _page,
      search: search.isEmpty ? null : search,
    );

    final adjustedItems = _applyReadMarkers(result.items);
    if (reset) {
      chats.assignAll(adjustedItems);
    } else {
      chats.addAll(adjustedItems);
    }
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);

    hasMore.value = result.hasMore;
    _page = result.page + 1;

    isLoading.value = false;
    isLoadingMore.value = false;
    if (_markersDirty) {
      _markersDirty = false;
      unawaited(_saveMarkers());
    }

    update();
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

  Future<void> _initSocket() async {
    _currentUserId ??= await getUserIdFromPrefs();
    final userId = _currentUserId;
    if (userId == null || socket != null || _isSocketInitializing) return;
    _isSocketInitializing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _token =
          prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
      final uri = Uri.parse(ApiEndpoints.baseUrl);
      _baseSocketUrl = '${uri.scheme}://${uri.host}';

      socket = SocketService(
        socketUrl: _baseSocketUrl!,
        token: _token,
        path: '/haraj/socket.io',
      );

      _registerSocketHandlers();
      _connectSocket(userId);
    } finally {
      _isSocketInitializing = false;
    }
  }

  void _registerSocketHandlers() {
    if (socket == null || _listenersAttached) return;
    _listenersAttached = true;

    socket?.ensureDebugLogging();
    socket?.onConnectError((_) => _retrySocket());
    socket?.onError((_) => _retrySocket());

    socket?.onNotificationCount(_handleNotificationCount);
  }

  void _connectSocket(int userId) {
    if (socket == null) return;

    void joinRooms() {
      socket?.joinRoom(userId);
    }

    if (socket?.isConnected != true) {
      socket?.connect(query: {'userId': userId}, onConnect: joinRooms);
    } else {
      joinRooms();
    }
  }

  void _retrySocket() {
    if (_triedAltSocketPath) return;
    _triedAltSocketPath = true;
    _listenersAttached = false;

    socket?.disconnect();
    final baseUrl = _baseSocketUrl;
    if (baseUrl == null) return;

    socket = SocketService(
      socketUrl: baseUrl,
      token: _token,
      path: '/socket.io',
    );

    final userId = _currentUserId;
    if (userId != null) {
      _registerSocketHandlers();
      _connectSocket(userId);
    }
  }

  void _handleNotificationCount(dynamic data) {
    int? parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    final chatId =
        data is Map<String, dynamic>
            ? parseInt(data['chat_id'] ?? data['chatId'])
            : null;
    final count =
        data is Map<String, dynamic>
            ? parseInt(data['count'] ?? data['unread'])
            : null;

    if (chatId == null || count == null) return;

    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    final marker = _readMarkers[chatId];
    if (marker != null && marker.matches(chats[idx])) {
      if (chats[idx].unreadCount != 0) {
        chats[idx] = chats[idx].copyWith(unreadCount: 0);
        chats.refresh();
        unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
      }
      return;
    }

    if (count > 0 && _readMarkers.remove(chatId) != null) {
      _markersDirty = true;
      unawaited(_saveMarkers());
    }
    chats[idx] = chats[idx].copyWith(unreadCount: count);
    chats.refresh();

    // Optional: keep a running total if backend sends per-chat counts.
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  void clearUnread(int? chatId) {
    if (chatId == null) return;
    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;
    chats[idx] = chats[idx].copyWith(unreadCount: 0);
    chats.refresh();
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  void markChatRead(int chatId, {String? lastMessage, String? lastTime}) {
    _readMarkers[chatId] = _ReadMarker(
      lastMessage: lastMessage ?? '',
      lastTime: lastTime ?? '',
    );
    _markersDirty = true;
    unawaited(_saveMarkers());

    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    final message = (lastMessage ?? '').trim();
    final time = (lastTime ?? '').trim();
    final current = chats[idx];
    final updated = current.copyWith(
      message: message.isNotEmpty ? message : current.message,
      time: time.isNotEmpty ? time : current.time,
      unreadCount: 0,
    );

    if (idx == 0) {
      chats[0] = updated;
    } else {
      chats.removeAt(idx);
      chats.insert(0, updated);
    }
    chats.refresh();
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  List<ChatEntity> _applyReadMarkers(List<ChatEntity> items) {
    if (_readMarkers.isEmpty) return items;
    final updated = <ChatEntity>[];
    for (final chat in items) {
      final id = chat.id;
      if (id == null) {
        updated.add(chat);
        continue;
      }
      final marker = _readMarkers[id];
      if (marker == null) {
        updated.add(chat);
        continue;
      }
      if (marker.matches(chat)) {
        updated.add(
          chat.unreadCount == 0 ? chat : chat.copyWith(unreadCount: 0),
        );
      } else {
        _readMarkers.remove(id);
        _markersDirty = true;
        updated.add(chat);
      }
    }
    return updated;
  }

  String _markersKey(int userId) => 'chat_read_markers_$userId';

  Future<void> _loadMarkersIfNeeded(int userId) async {
    if (_markersLoaded && _markersUserId == userId) return;
    _markersLoaded = true;
    _markersUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_markersKey(userId));
    _readMarkers.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _readMarkers.clear();
        decoded.forEach((key, value) {
          final id = int.tryParse(key.toString());
          if (id == null || value is! Map) return;
          _readMarkers[id] = _ReadMarker(
            lastMessage: value['lastMessage']?.toString() ?? '',
            lastTime: value['lastTime']?.toString() ?? '',
          );
        });
      }
    } catch (_) {
      // Ignore corrupted cache.
    }
  }

  Future<void> _saveMarkers() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (_readMarkers.isEmpty) {
      await prefs.remove(_markersKey(userId));
      return;
    }
    final payload = <String, dynamic>{};
    for (final entry in _readMarkers.entries) {
      payload[entry.key.toString()] = {
        'lastMessage': entry.value.lastMessage,
        'lastTime': entry.value.lastTime,
      };
    }
    await prefs.setString(_markersKey(userId), jsonEncode(payload));
  }
}

class _ReadMarker {
  final String lastMessage;
  final String lastTime;

  _ReadMarker({required this.lastMessage, required this.lastTime});

  bool matches(ChatEntity chat) {
    final time = chat.time.trim();
    if (lastTime.isNotEmpty && time.isNotEmpty) {
      final markerTime = DateTime.tryParse(lastTime);
      final chatTime = DateTime.tryParse(time);
      if (markerTime != null && chatTime != null) {
        if (markerTime.isAtSameMomentAs(chatTime)) return true;
      } else if (lastTime == time) {
        return true;
      }
    }
    final message = chat.message.trim();
    if (lastMessage.isNotEmpty &&
        message.isNotEmpty &&
        lastMessage == message) {
      return true;
    }
    return false;
  }
}
