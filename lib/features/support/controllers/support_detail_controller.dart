// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:haraj_adan_app/core/network/endpoints.dart';
// import 'package:haraj_adan_app/core/network/socket_service.dart';
// import 'package:haraj_adan_app/core/storage/user_storage.dart';
// import 'package:haraj_adan_app/data/models/support_message_model.dart';
// import 'package:haraj_adan_app/domain/entities/support_message_entity.dart';
// import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SupportDetailController extends GetxController {
//   final SupportRepository repository;
//   final int chatId;
//   final String chatName;
//   final SocketService? initialSocket;

//   SupportDetailController(
//     this.repository, {
//     required this.chatId,
//     required this.chatName,
//     this.initialSocket,
//   });

//   final messages = <SupportMessageEntity>[].obs;
//   final isLoading = true.obs;
//   final isLoadingMore = false.obs;
//   final hasMore = true.obs;
//   final isSending = false.obs;
//   final scrollController = ScrollController();

//   SocketService? socket;
//   int _page = 1;
//   int? _currentUserId;
//   String? _token;
//   bool _triedAltSocketPath = false;
//   bool _listenersAttached = false;

//   void _log(String message, [dynamic data]) {
//     // ignore: avoid_print
//     print('[SupportDetail] $message${data != null ? ' => $data' : ''}');
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     scrollController.addListener(_onScroll);
//     _init();
//   }

//   void _onScroll() {
//     if (scrollController.position.pixels <=
//         scrollController.position.minScrollExtent + 80) {
//       loadMessages();
//     }
//   }

//   Future<void> _init() async {
//     _currentUserId = await getUserIdFromPrefs();
//     await loadMessages(reset: true);
//     await _initSocket();
//   }

//   Future<void> loadMessages({bool reset = false}) async {
//     if (reset) {
//       _page = 1;
//       hasMore.value = true;
//     } else {
//       if (!hasMore.value || isLoadingMore.value) return;
//     }

//     if (reset) {
//       isLoading.value = true;
//     } else {
//       isLoadingMore.value = true;
//     }

//     double? distanceFromBottom;
//     if (!reset && scrollController.hasClients) {
//       final pos = scrollController.position;
//       distanceFromBottom = pos.maxScrollExtent - pos.pixels;
//     }

//     final result = await repository.getMessages(chatId: chatId, page: _page);

//     if (reset) {
//       messages.assignAll(result.items);
//       _scrollToBottom();
//     } else {
//       messages.insertAll(0, result.items);
//       if (distanceFromBottom != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (!scrollController.hasClients) return;
//           final max = scrollController.position.maxScrollExtent;
//           final target = (max - distanceFromBottom!).clamp(
//             scrollController.position.minScrollExtent,
//             scrollController.position.maxScrollExtent,
//           );
//           scrollController.jumpTo(target);
//         });
//       }
//     }

//     hasMore.value = result.hasMore;
//     _page = result.page + 1;

//     isLoading.value = false;
//     isLoadingMore.value = false;

//     _sendReadReceiptsIfNeeded();
//   }

//   Future<void> _initSocket() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
//     final userId = await getUserIdFromPrefs();
//     _currentUserId = userId;
//     if (userId == null) return;

//     _triedAltSocketPath = false;
//     _listenersAttached = false;

//     socket =
//         initialSocket ??
//         SocketService(
//           socketUrl: ApiEndpoints.supportSocketUrl,
//           token: _token,
//           path: '/haraj/socket.io',
//         );

//     _registerSocketHandlers();
//     _connectSocket(userId);
//   }

//   void _connectSocket(int userId, {VoidCallback? onReady}) {
//     if (socket == null) return;

//     void joinRooms() {
//       _log('joining support rooms', {'userId': userId, 'chatId': chatId});
//       socket?.joinRoom(userId);
//       socket?.joinSupportRoom(chatId);
//       _sendReadReceiptsIfNeeded();
//       onReady?.call();
//     }

//     if (socket?.isConnected != true) {
//       _log('connecting socket', {'userId': userId, 'chatId': chatId});
//       socket?.connect(
//         query: {'userId': userId, if (_token != null) 'token': _token},
//         onConnect: joinRooms,
//       );
//     } else {
//       joinRooms();
//     }
//   }

//   void _retrySocket() {
//     if (_triedAltSocketPath) return;
//     _triedAltSocketPath = true;
//     _listenersAttached = false;
//     _log('retrying socket with fallback path', null);
//     socket?.disconnect();
//     socket = SocketService(
//       socketUrl: ApiEndpoints.supportSocketUrl,
//       token: _token,
//       path: '/socket.io',
//     );
//     final userId = _currentUserId;
//     if (userId != null) {
//       _registerSocketHandlers();
//       _connectSocket(userId);
//     }
//   }

//   void sendText(String text) async {
//     final userId = _currentUserId ?? await getUserIdFromPrefs();
//     _currentUserId = userId;
//     final trimmed = text.trim();
//     if (userId == null || trimmed.isEmpty) return;
//     _log('sendText', {'chatId': chatId, 'userId': userId, 'text': trimmed});

//     final pending = SupportMessageModel.pendingText(
//       text: trimmed,
//       senderId: userId,
//       isAdmin: false,
//     );

//     messages.add(pending);
//     _scrollToBottom();

//     _sendViaSocket(userId: userId, text: trimmed);
//   }

//   Future<void> uploadMedia({
//     required String filePath,
//     required String type,
//     bool isAdmin = false,
//   }) async {
//     final userId = _currentUserId;
//     if (userId == null) return;

//     isSending.value = true;
//     try {
//       final uploaded = await repository.uploadMedia(
//         chatId: chatId,
//         userId: userId,
//         type: type,
//         filePath: filePath,
//         isAdmin: isAdmin,
//       );
//       if (uploaded != null) {
//         messages.add(uploaded);
//         _scrollToBottom();
//         _sendReadReceiptsIfNeeded();
//       }
//     } finally {
//       isSending.value = false;
//     }
//   }

//   void _sendViaSocket({required int userId, required String text}) {
//     socket ??=
//         initialSocket ??
//         SocketService(
//           socketUrl: ApiEndpoints.supportSocketUrl,
//           token: _token,
//           path: '/haraj/socket.io',
//         );
//     _connectSocket(
//       userId,
//       onReady: () {
//         _log('socket ready, emitting sendSupportMessage');
//         socket?.sendSupportMessage(
//           userId: userId,
//           message: {
//             'type': 'text',
//             'message': text,
//             'sender_id': userId,
//             'is_admin': 0,
//             'support_chat_id': chatId,
//           },
//           chatId: chatId,
//         );
//         _sendReadReceiptsIfNeeded();
//       },
//     );
//     _registerSocketHandlers();
//   }

//   void _sendReadReceiptsIfNeeded() {
//     final userId = _currentUserId;
//     if (userId == null) return;
//     final unreadIds =
//         messages
//             .where(
//               (m) =>
//                   m.id != null &&
//                   !m.isRead &&
//                   (m.senderId == null || m.senderId != userId),
//             )
//             .map((m) => m.id!)
//             .toList();
//     if (unreadIds.isEmpty) return;
//     socket?.sendSupportReadReceipt(chatId, unreadIds);
//   }

//   bool isFromCurrentUser(SupportMessageEntity msg) {
//     if (_currentUserId == null) return !msg.isAdmin;
//     return msg.senderId == _currentUserId;
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!scrollController.hasClients) return;
//       scrollController.animateTo(
//         scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   @override
//   void onClose() {
//     scrollController.dispose();
//     socket?.disconnect();
//     super.onClose();
//   }

//   int? _parseInt(dynamic value) {
//     if (value is num) return value.toInt();
//     return int.tryParse(value?.toString() ?? '');
//   }

//   void _registerSocketHandlers() {
//     if (socket == null || _listenersAttached) return;
//     _listenersAttached = true;
//     socket?.ensureDebugLogging(logger: _log);
//     socket?.onConnectError((data) {
//       _log('socket connect_error', data);
//       _retrySocket();
//     });
//     socket?.onError((data) {
//       _log('socket error', data);
//       _retrySocket();
//     });

//     socket?.onNewSupportMessage((data) {
//       final incomingChatId =
//           data is Map<String, dynamic>
//               ? _parseInt(
//                 data['support_chat_id'] ?? data['chat_id'] ?? data['chatId'],
//               )
//               : null;
//       if (incomingChatId != null && incomingChatId != chatId) return;
//       if (data is Map<String, dynamic>) {
//         final message = SupportMessageModel.fromMap(data);
//         final incomingId = message.id;
//         _log('new message', message);
//         final currentUserId = _currentUserId;

//         if (incomingId != null &&
//             messages.any((m) => m.id != null && m.id == incomingId)) {
//           return;
//         }

//         if (currentUserId != null &&
//             message.senderId == currentUserId &&
//             message.id != null) {
//           final pendingIndex = messages.indexWhere(
//             (m) =>
//                 m.id == null &&
//                 m.senderId == currentUserId &&
//                 m.message == message.message &&
//                 m.type == message.type,
//           );
//           if (pendingIndex != -1) {
//             messages[pendingIndex] = message;
//             messages.refresh();
//             _scrollToBottom();
//             _sendReadReceiptsIfNeeded();
//             return;
//           }
//         }

//         messages.add(message);
//         _scrollToBottom();
//         _sendReadReceiptsIfNeeded();
//       }
//     });

//     socket?.onSupportMessagesRead((data) {
//       if (data is Map<String, dynamic>) {
//         final ids = data['messageIds'] ?? data['ids'];
//         if (ids is List) {
//           final readIds =
//               ids
//                   .map((e) {
//                     if (e is num) return e.toInt();
//                     return int.tryParse(e.toString());
//                   })
//                   .whereType<int>()
//                   .toSet();

//           messages.value =
//               messages
//                   .map(
//                     (m) => SupportMessageModel(
//                       id: m.id,
//                       message: m.message,
//                       type: m.type,
//                       senderId: m.senderId,
//                       isAdmin: m.isAdmin,
//                       isRead:
//                           m.isRead || (m.id != null && readIds.contains(m.id)),
//                       createdAt: m.createdAt,
//                       mediaUrl: m.mediaUrl,
//                     ),
//                   )
//                   .toList();
//         }
//       }
//     });
//   }
// }

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
    }
  }

  Future<void> _init() async {
    _currentUserId = await getUserIdFromPrefs();
    await _loadToken();
    await loadMessages(reset: true);
    await _initSocket();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('_accessToken') ?? prefs.getString('_loginToken');
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

      // خليه مثل الشات: userId فقط (والتوكن موجود بالـ socket token غالباً)
      socket?.connect(query: {'userId': userId}, onConnect: joinRooms);
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
        // Payload مُسطّح + أسماء مختلفة للحقول (يغطي أغلب باك-إندات)
        final payload = <String, dynamic>{
          // identifiers
          'support_chat_id': chatId,
          'chat_id': chatId,
          'chatId': chatId,

          'user_id': userId,
          'userId': userId,
          'sender_id': userId,
          'senderId': userId,

          // content
          'type': 'text',
          'message': text,
          'text': text,
          'content': text,

          // flags
          'is_admin': 0,
          'isAdmin': 0,
        };

        _log('emitting sendSupportMessage', payload);

        // نفس دالتك الحالية بدون تعديل SocketService
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
      // قبول chatId بأي اسم محتمل
      final incomingChatId =
          data is Map<String, dynamic>
              ? _parseInt(
                data['support_chat_id'] ??
                    data['chat_id'] ??
                    data['chatId'] ??
                    data['supportChatId'],
              )
              : null;

      if (incomingChatId != null && incomingChatId != chatId) return;

      if (data is Map<String, dynamic>) {
        final message = SupportMessageModel.fromMap(data);
        final incomingId = message.id;
        _log('newSupportMessage', data);

        // منع التكرار
        if (incomingId != null &&
            messages.any((m) => m.id != null && m.id == incomingId)) {
          return;
        }

        // استبدال pending لو الرسالة نفس المرسل ونفس النص
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
