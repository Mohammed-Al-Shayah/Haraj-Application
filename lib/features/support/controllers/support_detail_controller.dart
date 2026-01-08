import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/error/error_model.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/data/models/support_message_model.dart';
import 'package:haraj_adan_app/domain/entities/paginated_result.dart';
import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportDetailController extends GetxController {
  final SupportRepository repository;
  final int chatId;
  final String chatName;
  final SocketService? initialSocket;

  final int? initialUserId;
  final int? partnerId;

  SupportDetailController(
    this.repository,
    this.initialSocket, {
    required this.chatId,
    required this.chatName,
    this.initialUserId,
    this.partnerId,
  });

  final messages = <SupportMessageEntity>[].obs;
  final partnerPresence = Rxn<PresenceStatus>();

  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSending = false.obs;

  final scrollController = ScrollController();

  SocketService? socket;

  static const int _pageSize = 20;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  String? _token;

  bool _triedAltSocketPath = false;
  bool _listenersAttached = false;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _pendingSyncAfterLoad = false;
  bool _isHandlingUnauthorized = false;

  bool _isAdminUser = false;
  bool _socketReady = false;
  int _nextOlderPage = 1;
  _PagePayload? _latestPagePayload;

  bool _userScrolledUp = false;

  DateTime? _lastLoadMoreAt;
  static const Duration _loadMoreCooldown = Duration(milliseconds: 0);

  void _log(String message, [dynamic data]) {
    if (kDebugMode) {
      print('[SupportDetail] $message${data != null ? ' => $data' : ''}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    update();
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

  // ---------------------------
  // Infinite scroll up
  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoading.value || isLoadingMore.value) return;
    if (!hasMore.value) return;

    final direction = scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.forward) {
      _userScrolledUp = true;
    }
    if (!_userScrolledUp) return;

    final isNearTop =
        scrollController.position.pixels <=
        scrollController.position.minScrollExtent + 120;

    if (!isNearTop) return;

    final now = DateTime.now();
    if (_lastLoadMoreAt != null &&
        now.difference(_lastLoadMoreAt!) < _loadMoreCooldown) {
      return;
    }
    _lastLoadMoreAt = now;

    loadMessages();
    update();
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
    _isAdminUser = _extractAdminFlag(prefs);
  }

  Future<void> _ensureToken() async {
    if ((_token ?? '').isNotEmpty) return;
    await _loadToken();
  }

  // ---------------------------
  Future<void> loadMessages({bool reset = false}) async {
    if (reset) {
      _userScrolledUp = false;
      _nextOlderPage = 1;
      _latestPagePayload = null;
      await _loadLatestPage();
      return;
    }

    if (!hasMore.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    double? distanceFromBottom;
    if (scrollController.hasClients) {
      final pos = scrollController.position;
      distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    }

    try {
      final result = await _fetchPage(_nextOlderPage);
      final ordered = _sortedMessages(result.items);
      for (final msg in ordered) {
        _insertMessageInOrder(msg);
      }
      _restoreScroll(distanceFromBottom);

      _nextOlderPage -= 1;
      hasMore.value = _nextOlderPage >= 1;
    } on ErrorModel catch (error) {
      _log('loadMessages error', error);
      _handleError(error, title: AppStrings.supportTitle);
    } catch (error, stack) {
      _log('loadMessages unexpected', {'error': error, 'stack': stack});
      AppSnack.error(AppStrings.errorTitle, 'Unable to load messages');
    } finally {
      isLoadingMore.value = false;
    }

    if (_pendingSyncAfterLoad && !isLoading.value && !isLoadingMore.value) {
      _pendingSyncAfterLoad = false;
      _syncLatest();
    }
  }

  Future<void> _loadLatestPage() async {
    isLoading.value = true;
    try {
      _latestPagePayload = null;
      final payload = await _resolveLatestPagePayload();
      messages.assignAll(_sortedMessages(payload.result.items));
      _scrollToBottom(force: true);
      _nextOlderPage = payload.page - 1;
      hasMore.value = _nextOlderPage >= 1;
    } on ErrorModel catch (error) {
      _log('loadLatestPage error', error);
      _handleError(error, title: AppStrings.supportTitle);
    } catch (error, stack) {
      _log('loadLatestPage unexpected', {'error': error, 'stack': stack});
      AppSnack.error(AppStrings.errorTitle, 'Unable to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<PaginatedResult<SupportMessageEntity>> _fetchPage(int page) {
    return repository.getMessages(chatId: chatId, page: page, limit: _pageSize);
  }

  Future<_PagePayload> _resolveLatestPagePayload() async {
    if (_latestPagePayload != null) return _latestPagePayload!;

    int cursor = 1;
    PaginatedResult<SupportMessageEntity>? candidate;

    while (true) {
      final result = await _fetchPage(cursor);
      if (result.items.isEmpty) break;
      candidate = result;
      if (result.items.length < _pageSize) {
        _latestPagePayload = _PagePayload(cursor, result);
        return _latestPagePayload!;
      }
      cursor *= 2;
    }

    if (candidate == null) {
      final first = await _fetchPage(1);
      _latestPagePayload = _PagePayload(1, first);
      return _latestPagePayload!;
    }

    int low = cursor ~/ 2;
    int high = cursor;

    while (low + 1 < high) {
      final mid = (low + high) ~/ 2;
      final result = await _fetchPage(mid);
      if (result.items.isEmpty) {
        high = mid;
      } else {
        candidate = result;
        if (result.items.length < _pageSize) {
          _latestPagePayload = _PagePayload(mid, result);
          return _latestPagePayload!;
        }
        low = mid;
      }
    }

    _latestPagePayload = _PagePayload(low, candidate ?? await _fetchPage(low));
    return _latestPagePayload!;
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
    update();
  }

  void _connectSocket(int userId, {VoidCallback? onReady}) {
    if (socket == null) return;

    void joinRooms() {
      _log('join support rooms', {'userId': userId, 'chatId': chatId});
      socket?.joinRoom(userId);
      socket?.joinSupportRoom(chatId);
      if (_isAdminUser) socket?.joinSupportAdminsRoom();

      _sendReadReceiptsIfNeeded();
      _socketReady = true;
      onReady?.call();
    }

    if (socket?.isConnected != true) {
      final query = <String, dynamic>{
        'userId': userId,
        if ((_token ?? '').isNotEmpty) 'token': _token,
      };
      socket?.connect(query: query, onConnect: joinRooms);
      update();
    } else {
      joinRooms();
      update();
    }
    update();
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
    update();
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

    socket?.onDisconnect((_) {
      _socketReady = false;
    });

    socket?.onNewSupportMessage(_handleIncomingSupportMessage);

    socket?.onUserOnline(
      (data) => _handlePresenceStatus(data, PresenceStatus.online),
    );
    socket?.onUserOffline(
      (data) => _handlePresenceStatus(data, PresenceStatus.offline),
    );
    socket?.onPresenceUpdate(_handlePresenceUpdate);

    socket?.onSupportMessagesRead(_handleSupportMessagesRead);
    update();
  }

  // ---------------------------
  void sendText(String text) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;

    final trimmed = text.trim();
    if (userId == null || trimmed.isEmpty) return;

    await _ensureToken();

    final pending = SupportMessageModel.pendingText(
      text: trimmed,
      senderId: userId,
      isAdmin: _isAdminUser,
    );

    _insertMessageInOrder(pending);
    messages.refresh();
    update();
    _scrollToBottom(force: true);

    _sendViaSocket(userId: userId, text: trimmed);
    update();
  }

  Future<void> uploadMedia({
    required String filePath,
    required String type,
    bool? isAdmin,
  }) async {
    final userId = _currentUserId ?? await getUserIdFromPrefs();
    _currentUserId = userId;
    if (userId == null) return;

    isSending.value = true;
    try {
      final effectiveAdmin = isAdmin ?? _isAdminUser;

      final uploaded = await repository.uploadMedia(
        chatId: chatId,
        userId: userId,
        type: type,
        filePath: filePath,
        isAdmin: effectiveAdmin,
      );

      if (uploaded != null) {
        _insertMessageInOrder(uploaded);
        messages.refresh();
        update();
        _scrollToBottom(force: true);
        _sendReadReceiptsIfNeeded();
        update();
      }
    } on ErrorModel catch (error) {
      _log('uploadMedia error', error);
      _handleError(error, title: AppStrings.supportTitle);
    } catch (error, stack) {
      _log('uploadMedia unexpected', {'error': error, 'stack': stack});
      AppSnack.error(AppStrings.errorTitle, 'Unable to upload media');
    } finally {
      isSending.value = false;
      update();
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
          'is_admin': _isAdminUser,
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
    update();
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
        update();
        _scrollToBottom(force: true);
        _sendReadReceiptsIfNeeded();
        return;
      }
      update();
    }

    _insertMessageInOrder(message);
    messages.refresh();
    update();
    _scrollToBottom();
    _sendReadReceiptsIfNeeded();
    update();
  }

  void _handlePresenceStatus(dynamic data, PresenceStatus status) {
    final payload = _coerceToMap(data);
    if (payload == null) return;

    final userId = _parseInt(
      payload['userId'] ?? payload['user_id'] ?? payload['id'],
    );
    if (!_shouldUpdatePresence(userId)) return;

    partnerPresence.value = status;
    update();
  }

  void _handlePresenceUpdate(dynamic data) {
    final payload = _coerceToMap(data);
    if (payload == null) return;

    final userId = _parseInt(
      payload['userId'] ?? payload['user_id'] ?? payload['id'],
    );
    if (!_shouldUpdatePresence(userId)) return;

    final onlineValue =
        payload['isOnline'] ??
        payload['online'] ??
        payload['status'] ??
        payload['is_online'];

    final isOnline = _parseBool(onlineValue);
    partnerPresence.value =
        isOnline ? PresenceStatus.online : PresenceStatus.offline;
    update();
  }

  // ---------------------------
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _syncLatest(),
    );
    update();
  }

  Future<void> _syncLatest() async {
    if (_isSyncing) return;
    if (socket?.isConnected == true || _socketReady) return;

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
    } on ErrorModel catch (error) {
      _log('syncLatest error', error);
      _handleError(error, title: AppStrings.supportTitle);
    } catch (error, stack) {
      _log('syncLatest unexpected', {'error': error, 'stack': stack});
    } finally {
      _isSyncing = false;
    }
    update();
  }

  void _mergeLatest(List<SupportMessageEntity> latest) {
    if (latest.isEmpty) return;

    final ordered = _normalizeLatestOrder(latest);
    final existingIds =
        messages.where((m) => m.id != null).map((m) => m.id!).toSet();

    final userId = _currentUserId;
    var changed = false;

    for (final incoming in ordered) {
      final incomingId = incoming.id;
      if (incomingId != null && existingIds.contains(incomingId)) continue;

      if (userId != null && incoming.senderId == userId && incomingId != null) {
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
        update();
      }

      _insertMessageInOrder(incoming);
      if (incomingId != null) existingIds.add(incomingId);
      changed = true;
      update();
    }

    if (changed) {
      messages.refresh();
      update();
      _scrollToBottom();
      _sendReadReceiptsIfNeeded();
      update();
    }
    update();
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
    update();
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

    messages.refresh();
    update();
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
    update();
  }

  // ---------------------------
  bool isFromCurrentUser(SupportMessageEntity msg) {
    final id = _currentUserId;
    if (id == null) return false;
    update();
    return msg.senderId == id;
  }

  // ---------------------------

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(scrollController.position.minScrollExtent);
    });
    update();
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
    update();
  }

  // ---------------------------
  List<SupportMessageEntity> _sortedMessages(List<SupportMessageEntity> items) {
    final copy = List<SupportMessageEntity>.from(items);
    copy.sort((a, b) => _compareMessages(b, a));
    update();
    return copy;
  }

  void _insertMessageInOrder(SupportMessageEntity message) {
    for (var index = 0; index < messages.length; index++) {
      if (_compareMessages(message, messages[index]) > 0) {
        messages.insert(index, message);
        return;
      }
    }
    messages.add(message);
    update();
  }

  int _compareMessages(SupportMessageEntity a, SupportMessageEntity b) {
    final primary = _messageTimestamp(a).compareTo(_messageTimestamp(b));
    if (primary != 0) return primary;
    final aId = a.id ?? 0;
    final bId = b.id ?? 0;
    return aId.compareTo(bId);
  }

  DateTime _messageTimestamp(SupportMessageEntity msg) {
    if (msg.createdAt != null) return msg.createdAt!;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // ---------------------------
  void _handleError(ErrorModel error, {String? title}) {
    final header = title ?? AppStrings.errorTitle;
    if (_isUnauthorized(error)) {
      AppSnack.error(header, AppStrings.loginRequired);
      _handleUnauthorized();
      return;
    }
    AppSnack.error(header, error.message);
  }

  bool _isUnauthorized(ErrorModel error) {
    final status = error.status.toLowerCase();
    final message = error.message.toLowerCase();
    return status.contains('401') ||
        status.contains('unauthor') ||
        message.contains('401') ||
        message.contains('unauthor') ||
        message.contains('expired');
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('_accessToken');
    await prefs.remove('_loginToken');
    await prefs.remove('_userData');

    Get.offAllNamed(Routes.loginScreen);
    update();
  }

  // ---------------------------
  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool _shouldUpdatePresence(int? userId) {
    if (partnerId == null) return false;
    if (userId == null) return false;
    return userId == partnerId;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' ||
          lower == '1' ||
          lower == 'online' ||
          lower == 'available';
    }
    return false;
  }

  bool _extractAdminFlag(SharedPreferences prefs) {
    final userJson = prefs.getString('_userData');
    if (userJson == null) return false;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        final candidate =
            decoded['is_admin'] ??
            decoded['isAdmin'] ??
            decoded['admin'] ??
            decoded['role'] ??
            decoded['user_type'];
        if (candidate != null) return _parseBool(candidate);
      }
    } catch (_) {}
    return false;
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
      update();
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

enum PresenceStatus { online, offline }

class _PagePayload {
  final int page;
  final PaginatedResult<SupportMessageEntity> result;

  _PagePayload(this.page, this.result);
}
