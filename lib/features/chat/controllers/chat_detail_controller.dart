import 'package:get/get.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/chat_detail_repository.dart';

class ChatDetailController extends GetxController {
  final ChatDetailRepository repository;

  ChatDetailController(this.repository);

  var messages = <MessageEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  void loadMessages() async {
    isLoading.value = true;
    messages.value = await repository.getMessages();
    isLoading.value = false;
  }
}
