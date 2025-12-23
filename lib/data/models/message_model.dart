import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({required super.text, required super.isSender});

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(text: map['text'], isSender: map['isSender']);
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'isSender': isSender};
  }
}
