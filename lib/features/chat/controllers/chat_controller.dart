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
  static const int _pageSize = 10;

  Timer? _debounce;

  SocketService? socket;
  String? _token;
  String? _baseSocketUrl;

  int? _currentUserId;
  bool _listenersAttached = false;
  bool _triedAltSocketPath = false;
  bool _isSocketInitializing = false;

  // Read markers cache
  final Map<int, _ReadMarker> _readMarkers = {};
  bool _markersLoaded = false;
  bool _markersDirty = false;
  int? _markersUserId;

  @override
  void onInit() {
    super.onInit();
    loadChats(reset: true);
    _initSocket(); // best-effort
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    socket?.disconnect();
    super.onClose();
  }

  // ---------------------------
  // Public actions
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
      _finishLoading(reset);
      return;
    }

    await _loadMarkersIfNeeded(userId);
    await _initSocket(); // ensure socket exists

    final search = searchController.text.trim();
    final result = await repository.getChats(
      userId: userId,
      page: _page,
      limit: _pageSize,
      search: search.isEmpty ? null : search,
    );

    final adjusted = _applyReadMarkers(result.items);

    if (reset) {
      chats.assignAll(adjusted);
    } else {
      chats.addAll(adjusted);
    }

    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);

    hasMore.value = result.hasMore;
    _page = result.page + 1;

    _finishLoading(reset);

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

  void clearUnread(int? chatId) {
    if (chatId == null) return;
    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    if (chats[idx].unreadCount == 0) return;

    chats[idx] = chats[idx].copyWith(unreadCount: 0);
    chats.refresh();
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  void markChatRead(int chatId, {required String lastMessage, required String lastTime}) {
    _readMarkers[chatId] = _ReadMarker(lastMessage: lastMessage, lastTime: lastTime);
    _markersDirty = true;
    unawaited(_saveMarkers());

    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    final current = chats[idx];
    final updated = current.copyWith(
      message: lastMessage.trim().isNotEmpty ? lastMessage.trim() : current.message,
      time: lastTime.trim().isNotEmpty ? lastTime.trim() : current.time,
      unreadCount: 0,
    );

    // keep list ordering: move chat to top
    if (idx == 0) {
      chats[0] = updated;
    } else {
      chats.removeAt(idx);
      chats.insert(0, updated);
    }

    chats.refresh();
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  // ---------------------------
  // Socket lifecycle
  Future<void> _initSocket() async {
    _currentUserId ??= await getUserIdFromPrefs();
    final userId = _currentUserId;
    if (userId == null) return;

    if (socket != null || _isSocketInitializing) {
      // if socket exists, ensure joined
      _connectSocket(userId);
      return;
    }

    _isSocketInitializing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');

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

    socket!.ensureDebugLogging();

    socket!.onConnectError((_) => _retrySocket());
    socket!.onError((_) => _retrySocket());

    socket!.onNotificationCount(_handleNotificationCount);
  }

  void _connectSocket(int userId) {
    if (socket == null) return;

    void joinRooms() {
      socket!.joinRoom(userId);
    }

    if (socket!.isConnected != true) {
      socket!.connect(query: {'userId': userId}, onConnect: joinRooms);
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
    if (userId == null) return;

    _registerSocketHandlers();
    _connectSocket(userId);
  }

  void _handleNotificationCount(dynamic data) {
    int? parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    if (data is! Map) return;

    final map = data.map((k, v) => MapEntry(k.toString(), v));
    final chatId = parseInt(map['chat_id'] ?? map['chatId']);
    final count = parseInt(map['count'] ?? map['unread']);

    if (chatId == null || count == null) return;

    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    // If marker says already read => force to 0
    final marker = _readMarkers[chatId];
    if (marker != null && marker.matches(chats[idx])) {
      if (chats[idx].unreadCount != 0) {
        chats[idx] = chats[idx].copyWith(unreadCount: 0);
        chats.refresh();
      }
      unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
      return;
    }

    // if backend says there are unread => remove local marker
    if (count > 0 && _readMarkers.remove(chatId) != null) {
      _markersDirty = true;
      unawaited(_saveMarkers());
    }

    chats[idx] = chats[idx].copyWith(unreadCount: count);
    chats.refresh();
    unreadTotal.value = chats.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  // ---------------------------
  // Read markers
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
        updated.add(chat.unreadCount == 0 ? chat : chat.copyWith(unreadCount: 0));
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
      // ignore corrupted cache
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

  void _finishLoading(bool reset) {
    isLoading.value = false;
    isLoadingMore.value = false;
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

    final msg = chat.message.trim();
    if (lastMessage.isNotEmpty && msg.isNotEmpty && lastMessage == msg) {
      return true;
    }

    return false;
  }
}
