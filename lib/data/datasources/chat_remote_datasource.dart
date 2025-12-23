import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> fetchChats();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<ChatModel>> fetchChats() async {
    await Future.delayed(Duration(milliseconds: 300));
    final raw = [
      {
        'name': 'Emma Carter',
        'message': 'Good morning',
        'time': 'Today',
        'image':
            'https://i.pinimg.com/736x/8c/6d/db/8c6ddb5fe6600fcc4b183cb2ee228eb7.jpg',
        'status': 'online',
      },
      {
        'name': 'Sophia Miller',
        'message': 'How is it going?',
        'time': '17/6',
        'image': '',
        'status': 'offline',
      },
      {
        'name': 'James Wilson',
        'message': 'Are you available?',
        'time': 'Yesterday',
        'image':
            'https://i.pinimg.com/736x/0b/97/6f/0b976f0a7aa1aa43870e1812eee5a55d.jpg',
        'status': 'online',
      },
      {
        'name': 'Liam Anderson',
        'message': "Let's catch up later!",
        'time': '16/6',
        'image':
            'https://i.pinimg.com/736x/8c/6d/db/8c6ddb5fe6600fcc4b183cb2ee228eb7.jpg',
        'status': 'offline',
      },
    ];
    return raw.map((e) => ChatModel.fromMap(e)).toList();
  }
}
