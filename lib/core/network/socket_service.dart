
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  final String socketUrl;
  final String? token;
  final String? path;

  io.Socket? _socket;
  bool _debugLoggingAttached = false;

  SocketService({required this.socketUrl, this.token, this.path});

  bool get isConnected => _socket?.connected == true;

  // void connect({Map<String, dynamic>? query, void Function()? onConnect}) {
  //   final builder = io.OptionBuilder()
  //       .setTransports(['websocket', 'polling'])
  //       .disableAutoConnect()
  //       .setQuery(query ?? {})
  //       .setExtraHeaders(
  //         token != null ? {'Authorization': 'Bearer $token'} : {},
  //       );
  //   if (path != null) {
  //     builder.setPath(path!);
  //   }
  //   _socket = io.io(socketUrl, builder.build());
  //   if (onConnect != null) {
  //     _socket?.onConnect((_) => onConnect());
  //     _socket?.on('reconnect', (_) => onConnect());
  //   }
  //   _socket?.connect();
  // }

  void connect({Map<String, dynamic>? query, void Function()? onConnect}) {
    // 1) لو في Socket موجود، لا تعمله recreate
    if (_socket != null) {
      // حدّث query فقط إذا بدك (اختياري)
      if (_socket!.connected != true) {
        if (onConnect != null) {
          _socket!.off('connect'); // تجنب تكرار handlers
          _socket!.onConnect((_) => onConnect());
        }
        _socket!.connect();
      } else {
        onConnect?.call();
      }
      return;
    }

    // 2) أنشئ socket مرة واحدة
    final builder = io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .disableAutoConnect()
        .setQuery(query ?? {})
        .setExtraHeaders(
          token != null ? {'Authorization': 'Bearer $token'} : {},
        )
        .enableReconnection()
        .setReconnectionAttempts(999)
        .setReconnectionDelay(800);

    if (path != null) builder.setPath(path!);

    _socket = io.io(socketUrl, builder.build());

    // 3) ركب debug + handlers قبل connect
    ensureDebugLogging();

    if (onConnect != null) {
      _socket!.onConnect((_) => onConnect());
    }

    _socket!.connect();
  }

  void disconnect() {
    _debugLoggingAttached = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Join personal notification channel user_{userId}
  void joinRoom(int userId) {
    _socket?.emit('joinRoom', {'userId': userId});
  }

  /// Join a specific chat room user_chat_{chatId}
  void joinUserRoom(int chatId) {
    _socket?.emit('joinUserRoom', {
      'chatId': chatId,
      'chat_id': chatId,
      'room': 'user_chat_$chatId',
    });
  }

  void sendUserMessage({
    required int senderId,
    required int receiverId,
    required String message,
    String type = 'text',
    int? chatId,
  }) {
    _socket?.emit('sendUserMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      if (chatId != null) ...{'chatId': chatId, 'chat_id': chatId},
    });
  }

  void readUserMessages(int chatId) {
    _socket?.emit('readUserMessages', {'chat_id': chatId});
  }

  void onNewUserMessage(void Function(dynamic data) handler) {
    _socket?.on('newUserMessage', handler);
  }

  void onNotificationCount(void Function(dynamic data) handler) {
    _socket?.on('countChatNotifications', handler);
  }

  // void disconnect() {
  //   _socket?.disconnect();
  //   _socket?.dispose();
  //   _socket = null;
  // }

  /// Support chat helpers
  void joinSupportRoom(int chatId) {
    _socket?.emit('joinSupportChat', {
      'chatId': chatId,
      'room': 'support_chat_$chatId',
    });
  }

  // void sendSupportMessage({
  //   required int userId,
  //   required Map<String, dynamic> message,
  //   int? chatId,
  // }) {
  //   final payload = <String, dynamic>{'userId': userId, 'message': message};
  //   if (chatId != null) {
  //     payload['chatId'] = chatId;
  //     payload['support_chat_id'] = chatId;
  //     payload['chat_id'] = chatId;
  //     payload['room'] = 'support_chat_$chatId';
  //   }
  //   // _socket?.emit('sendSupportMessage', payload);
  //   _socket?.emitWithAck(
  //     'sendSupportMessage',
  //     payload,
  //     ack: (data) {
  //       print('[socket] ACK sendSupportMessage => $data');
  //     },
  //   );
  // }
  void sendSupportMessage({
    required int userId,
    required Map<String, dynamic> message,
    int? chatId,
  }) {
    final payload = <String, dynamic>{'userId': userId, 'message': message};

    if (chatId != null) {
      payload['chatId'] = chatId;
      payload['support_chat_id'] = chatId;
      payload['chat_id'] = chatId;
      payload['room'] = 'support_chat_$chatId';
    }

    if (kDebugMode) {
      print('[socket] sending sendSupportMessage payload => $payload');
    }

    _socket?.emitWithAck(
      'sendSupportMessage',
      payload,
      ack: (data) {
        if (kDebugMode) {
          print('[socket] ACK sendSupportMessage => $data');
        }
      },
    );
  }

  void onNewSupportMessage(void Function(dynamic data) handler) {
    _socket?.on('newSupportMessage', handler);
    _socket?.on('newSupportMessage', (data) {
      if (kDebugMode) {
        print('[socket] newSupportMessage => $data');
      }
    });

    _socket?.on('supportMessagesRead', (data) {
      if (kDebugMode) {
        print('[socket] supportMessagesRead => $data');
      }
    });
  }

  void sendSupportReadReceipt(int chatId, List<int> messageIds) {
    _socket?.emit('readSupportMessages', {
      'chatId': chatId,
      'messageIds': messageIds,
    });
  }

  void onSupportMessagesRead(void Function(dynamic data) handler) {
    _socket?.on('supportMessagesRead', handler);
  }

  /// Attach verbose listeners for debugging socket lifecycle.
  void ensureDebugLogging({void Function(String event, dynamic data)? logger}) {
    if (_debugLoggingAttached) return;
    _debugLoggingAttached = true;
    final log =
        logger ??
        (String event, dynamic data) {
          // ignore: avoid_print
          print('SocketService[$socketUrl] $event => $data');
        };
    _socket?.onConnect((_) => log('connect', null));
    _socket?.onDisconnect((_) => log('disconnect', null));
    _socket?.onConnectError((data) => log('connect_error', data));
    _socket?.onError((data) => log('error', data));
    _socket?.on('reconnect', (data) => log('reconnect', data));
  }

  void onConnectError(void Function(dynamic data) handler) {
    _socket?.onConnectError(handler);
  }

  void onError(void Function(dynamic data) handler) {
    _socket?.onError(handler);
  }
}
