import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  final String socketUrl;
  final String? token;

  io.Socket? _socket;

  SocketService({required this.socketUrl, this.token});

  bool get isConnected => _socket?.connected == true;

  void connect({Map<String, dynamic>? query}) {
    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery(query ?? {})
          .setExtraHeaders(
            token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .build(),
    );
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
}
