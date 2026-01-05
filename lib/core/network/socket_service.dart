import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  final String socketUrl;
  final String? token;
  final String? path;

  io.Socket? _socket;
  bool _debugLoggingAttached = false;

  SocketService({required this.socketUrl, this.token, this.path});

  bool get isConnected => _socket?.connected == true;

  void connect({Map<String, dynamic>? query, void Function()? onConnect}) {
    final builder = io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .disableAutoConnect()
        .setQuery(query ?? {})
        .setExtraHeaders(
          token != null ? {'Authorization': 'Bearer $token'} : {},
        );
    if (path != null) {
      builder.setPath(path!);
    }
    _socket = io.io(socketUrl, builder.build());
    if (onConnect != null) {
      _socket?.onConnect((_) => onConnect());
      _socket?.on('reconnect', (_) => onConnect());
    }
    _socket?.connect();
  }

  void joinUserRoom(int userId) {
    _socket?.emit('joinUserRoom', {'userId': userId});
  }

  void sendUserMessage({
    required int chatId,
    required String message,
    int? receiverId,
  }) {
    _socket?.emit('sendUserMessage', {
      'chat_id': chatId,
      'message': message,
      if (receiverId != null) 'receiver_id': receiverId,
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

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Support chat helpers
  void joinSupportRoom(int chatId) {
    _socket?.emit('joinSupportChat', {
      'chatId': chatId,
      'room': 'support_chat_$chatId',
    });
  }

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
    _socket?.emit('sendSupportMessage', payload);
  }

  void onNewSupportMessage(void Function(dynamic data) handler) {
    _socket?.on('newSupportMessage', handler);
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
