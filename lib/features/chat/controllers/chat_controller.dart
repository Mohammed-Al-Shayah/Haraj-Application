import 'package:get/get.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
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
    final userId = await getUserIdFromPrefs();
    if (userId == null) {
      chats.clear();
      isLoading.value = false;
      return;
    }
    chats.value = await repository.getChats(userId: userId);
    isLoading.value = false;
  }
}
