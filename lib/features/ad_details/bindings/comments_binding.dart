import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/comment_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/comment_repository_impl.dart';
import 'package:haraj_adan_app/domain/repositories/comment_repository.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/comment_controller.dart';

class CommentsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(client: Dio()));
    }

    Get.lazyPut<CommentsRemoteDataSource>(
      () => CommentsRemoteDataSourceImpl(Get.find<ApiClient>()),
    );

    Get.lazyPut<CommentsRepository>(() => CommentsRepositoryImpl(Get.find()));

    Get.lazyPut<CommentsController>(() => CommentsController(Get.find()));
  }
}
