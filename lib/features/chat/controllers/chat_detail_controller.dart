import 'package:get/get.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/chat_detail_repository.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/network/socket_service.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailController extends GetxController {
  final ChatDetailRepository repository;
  final int chatId;
  final SocketService? initialSocket;
  SocketService? socket;
  final String chatName;
  int? otherUserId;

  ChatDetailController(
    this.repository, {
    required this.chatId,
    required this.chatName,
    this.initialSocket,
    this.otherUserId,
  });

  var messages = <MessageEntity>[].obs;
  var isLoading = true.obs;
  final chatTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    chatTitle.value = chatName;
    loadMessages();
    _initSocket();
  }

  void loadMessages() async {
    isLoading.value = true;
    final userId = await getUserIdFromPrefs();
    if (userId == null) {
      isLoading.value = false;
      return;
    }
    messages.value = await repository.getMessages(
      chatId: chatId,
      userId: userId,
    );
    // حاول استخراج الـ otherUserId من أول رسالة إن وجد sender_id مختلف
    if (otherUserId == null && messages.isNotEmpty) {
      final first = messages.first;
      if (first is MessageModel && first.createdAt != null) {
        // لا يوجد sender_id داخل MessageEntity؛ يبقى الاحتفاظ بالقيمة الممررة
      }
    }
    isLoading.value = false;
  }

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('_accessToken');
    final userId = await getUserIdFromPrefs();

    if (userId == null) return;

    final uri = Uri.parse(ApiEndpoints.baseUrl);
    final baseSocketUrl = '${uri.scheme}://${uri.host}';
    socket =
        initialSocket ?? SocketService(socketUrl: baseSocketUrl, token: token);

    socket?.connect(query: {'userId': userId});
    socket?.joinUserRoom(userId);
    socket?.readUserMessages(chatId);
    socket?.onNewUserMessage((data) {
      if (data is Map<String, dynamic>) {
        messages.add(MessageModel.fromMap(data, currentUserId: userId));
      }
    });
    socket?.onNotificationCount((_) {});
  }

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (socket == null) {
      _initSocket();
    }
    messages.add(MessageModel(text: trimmed, isSender: true));
    socket?.sendUserMessage(
      chatId: chatId,
      message: trimmed,
      receiverId: otherUserId,
    );
    socket?.readUserMessages(chatId);
  }

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }
}
