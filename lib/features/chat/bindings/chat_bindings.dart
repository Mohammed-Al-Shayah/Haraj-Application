import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/chat_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/chat_repository_impl.dart';
import 'package:haraj_adan_app/domain/repositories/chat_repository.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_controller.dart';

class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(() => Dio(), fenix: true);
    Get.lazyPut<ApiClient>(() => ApiClient(client: Get.find<Dio>()), fenix: true);

    Get.lazyPut<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(Get.find<ChatRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<ChatController>(() => ChatController(Get.find<ChatRepository>()));
  }
}
