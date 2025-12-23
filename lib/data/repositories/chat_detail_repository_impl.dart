import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_detail_repository.dart';
import '../datasources/chat_detail_remote_data_source.dart';

class ChatDetailRepositoryImpl implements ChatDetailRepository {
  final ChatDetailRemoteDataSource remote;

  ChatDetailRepositoryImpl(this.remote);

  @override
  Future<List<MessageEntity>> getMessages() => remote.fetchMessages();
}
