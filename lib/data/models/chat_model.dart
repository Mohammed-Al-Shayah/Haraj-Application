import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required super.name,
    required super.message,
    required super.time,
    required super.image,
    required super.isOnline,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      name: map['name'],
      message: map['message'],
      time: map['time'],
      image: map['image'],
      isOnline: map['status'] == 'online',
    );
  }
}
