import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketEvents {
  static const connect = 'connect';
  static const disconnect = 'disconnect';

  // User chat
  static const joinRoom = 'joinRoom';
  static const joinUserRoom = 'joinUserRoom';
  static const sendUserMessage = 'sendUserMessage';
  static const readUserMessages = 'readUserMessages';

  static const newUserMessage = 'newUserMessage';
  static const newMessage = 'newMessage';
  static const newChatMessage = 'newChatMessage';
  static const message = 'message';

  static const countChatNotifications = 'countChatNotifications';

  // Support chat
  static const joinSupportChat = 'joinSupportChat';
  static const sendSupportMessage = 'sendSupportMessage';
  static const readSupportMessages = 'readSupportMessages';

  static const newSupportMessage = 'newSupportMessage';
  static const supportMessage = 'supportMessage';
  static const supportChatMessage = 'supportChatMessage';
  static const newSupportChatMessage = 'newSupportChatMessage';

  static const supportMessagesRead = 'supportMessagesRead';
}

class SocketService {
  final String socketUrl;
  final String? token;
  final String? path;

  io.Socket? _socket;
  bool _debugLoggingAttached = false;

  SocketService({required this.socketUrl, this.token, this.path});

  bool get isConnected => _socket?.connected == true;
  io.Socket? get raw => _socket;

  void connect({Map<String, dynamic>? query, void Function()? onConnect}) {
    // If already created:
    if (_socket != null) {
      if (_socket!.connected == true) {
        onConnect?.call();
        return;
      }

      if (onConnect != null) {
        _socket!.off(SocketEvents.connect);
        _socket!.onConnect((_) => onConnect());
      }

      _socket!.connect();
      return;
    }

    final builder = io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .disableAutoConnect()
        .setQuery(query ?? {})
        .setExtraHeaders(
          token != null && token!.isNotEmpty
              ? {'Authorization': 'Bearer $token'}
              : <String, String>{},
        )
        .enableReconnection()
        .setReconnectionAttempts(999)
        .setReconnectionDelay(800);

    if (path != null && path!.isNotEmpty) builder.setPath(path!);

    _socket = io.io(socketUrl, builder.build());

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

  // Generic helpers (cleaner usage inside controllers)
  void on(String event, void Function(dynamic data) handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [void Function(dynamic data)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  void emit(String event, Map<String, dynamic> data) {
    _socket?.emit(event, data);
  }

  // -------------------------
  // Rooms / emits (User)
  void joinRoom(int userId) {
    emit(SocketEvents.joinRoom, {'userId': userId});
  }

  void joinUserRoom(int chatId) {
    // emit(SocketEvents.joinUserRoom, {
    //   'chatId': chatId,
    //   'chat_id': chatId,
    //   'room': 'user_chat_$chatId',
    // });

    emit(SocketEvents.joinUserRoom, {'chat_id': chatId});
  }

  void sendUserMessage({
    required int senderId,
    required int receiverId,
    required String message,
    String type = 'text',
    int? chatId,
  }) {
    emit(SocketEvents.sendUserMessage, {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      if (chatId != null) ...{'chatId': chatId, 'chat_id': chatId},
    });
  }

  void readUserMessages(int chatId, {int? userId, int? receiverId}) {
    emit(SocketEvents.readUserMessages, {
      'chat_id': chatId,
      'chatId': chatId,
      if (userId != null) ...{'userId': userId, 'user_id': userId},
      if (receiverId != null) ...{
        'receiverId': receiverId,
        'receiver_id': receiverId,
      },
    });
  }

  void onNewUserMessage(void Function(dynamic data) handler) {
    void wrapped(dynamic data) {
      if (kDebugMode) {
        print('[socket] user message event => $data');
      }
      handler(data);
    }

    on(SocketEvents.newUserMessage, wrapped);
    on(SocketEvents.newMessage, wrapped);
    on(SocketEvents.newChatMessage, wrapped);
    on(SocketEvents.message, wrapped);
  }

  void onNotificationCount(void Function(dynamic data) handler) {
    on(SocketEvents.countChatNotifications, handler);
  }

  // -------------------------
  // Rooms / emits (Support)
  void joinSupportRoom(int chatId) {
    emit(SocketEvents.joinSupportChat, {
      'chatId': chatId,
      'support_chat_id': chatId,
      'supportChatId': chatId,
      'chat_id': chatId,
      'room': 'support_chat_$chatId',
    });
  }

  void sendSupportMessage({
    required int userId,
    required Map<String, dynamic> message,
    int? chatId, // kept for compatibility (even if backend ignores)
  }) {
    final payload = <String, dynamic>{
      'userId': userId,
      'message': message,
      // intentionally NOT forcing chatId here unless backend requires it
    };

    if (kDebugMode) {
      print('[socket] emit sendSupportMessage => $payload');
    }

    _socket?.emitWithAck(
      SocketEvents.sendSupportMessage,
      payload,
      ack: (data) {
        if (kDebugMode) {
          print('[socket] ACK sendSupportMessage => $data');
        }
      },
    );
  }

  void onNewSupportMessage(void Function(dynamic data) handler) {
    void wrapped(dynamic data) {
      if (kDebugMode) {
        print('[socket] support message event => $data');
      }
      handler(data);
    }

    on(SocketEvents.newSupportMessage, wrapped);
    on(SocketEvents.supportMessage, wrapped);
    on(SocketEvents.supportChatMessage, wrapped);
    on(SocketEvents.newSupportChatMessage, wrapped);

    on(SocketEvents.supportMessagesRead, (data) {
      if (kDebugMode) {
        print('[socket] supportMessagesRead => $data');
      }
    });
  }

  void sendSupportReadReceipt(int chatId, List<int> messageIds) {
    emit(SocketEvents.readSupportMessages, {
      'chatId': chatId,
      'support_chat_id': chatId,
      'supportChatId': chatId,
      'chat_id': chatId,
      'messageIds': messageIds,
    });
  }

  void onSupportMessagesRead(void Function(dynamic data) handler) {
    on(SocketEvents.supportMessagesRead, handler);
  }

  // -------------------------
  // Debug logging
  void ensureDebugLogging({void Function(String event, dynamic data)? logger}) {
    if (_debugLoggingAttached) return;
    _debugLoggingAttached = true;

    final log =
        logger ??
        (String event, dynamic data) {
          if (kDebugMode) {
            print('SocketService[$socketUrl] $event => $data');
          }
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
