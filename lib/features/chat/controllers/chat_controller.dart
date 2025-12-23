import 'package:get/get.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository repository;

  ChatController(this.repository);

  var chats = <ChatEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  void loadChats() async {
    isLoading.value = true;
    chats.value = await repository.getChats();
    isLoading.value = false;
  }
}
