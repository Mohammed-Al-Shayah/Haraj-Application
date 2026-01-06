import 'package:get/get.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';

class SupportDetailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportDetailController>(() {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final rawUserId = args['currentUserId'];
      final parsedUserId =
          rawUserId is int
              ? rawUserId
              : int.tryParse(rawUserId?.toString() ?? '');

      return SupportDetailController(
        Get.find<SupportRepository>(),
        null,
        chatId: args['chatId'],
        chatName: args['chatName'],
        initialUserId: parsedUserId,
      );
    });
  }
}
