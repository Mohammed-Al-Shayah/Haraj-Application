import '../models/message_model.dart';

abstract class ChatDetailRemoteDataSource {
  Future<List<MessageModel>> fetchMessages();
}

class ChatDetailRemoteDataSourceImpl implements ChatDetailRemoteDataSource {
  @override
  Future<List<MessageModel>> fetchMessages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      MessageModel(text: "Hey!", isSender: true),
      MessageModel(text: "Hi there, how’s your day going?", isSender: false),
      MessageModel(
        text:
            "Pretty good so far. I’ve been working on that new feature we talked about last week. It's taking shape.",
        isSender: true,
      ),
      MessageModel(
        text: "Nice. Let me know if you run into anything tricky.",
        isSender: false,
      ),
      MessageModel(
        text:
            "Will do. Actually, I might need your input on handling state cleanup when switching views. Got a minute later?",
        isSender: true,
      ),
      MessageModel(text: "Sure.", isSender: false),
      MessageModel(text: "Awesome, thanks!", isSender: true),
    ];
  }
}
