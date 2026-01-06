import 'package:get/get.dart';
import 'package:haraj_adan_app/data/datasources/chat_detail_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/chat_detail_repository_impl.dart';
import 'package:haraj_adan_app/domain/repositories/chat_detail_repository.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_detail_controller.dart';

class ChatDetailBindings extends Bindings {
  @override
  void dependencies() {
    // Data
    Get.lazyPut<ChatDetailRemoteDataSource>(
      () => ChatDetailRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );

    // Repo
    Get.lazyPut<ChatDetailRepository>(
      () => ChatDetailRepositoryImpl(Get.find<ChatDetailRemoteDataSource>()),
      fenix: true,
    );

    // Controller: args required
    Get.lazyPut<ChatDetailController>(() {
      final args = Get.arguments as Map<String, dynamic>? ?? const {};
      final chatId = args['chatId'] as int?;
      final chatName = args['chatName']?.toString() ?? 'Owner Name';
      final otherUserId = args['otherUserId'] as int?;

      if (chatId == null) {
        throw Exception('Missing chatId in Get.arguments');
      }

      return ChatDetailController(
        Get.find<ChatDetailRepository>(),
        chatId: chatId,
        chatName: chatName,
        otherUserId: otherUserId,
      );
    });
  }
}
