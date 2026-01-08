import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/support_remote_data_source.dart';
import 'package:haraj_adan_app/data/repositories/support_repository_impl.dart';
import 'package:haraj_adan_app/domain/repositories/support_repository.dart';
import 'package:haraj_adan_app/features/support/controllers/support_controller.dart';

class SupportBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => Dio(), fenix: true);
    }

    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(
        () => ApiClient(client: Get.find<Dio>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SupportRemoteDataSource>()) {
      Get.lazyPut<SupportRemoteDataSource>(
        () => SupportRemoteDataSourceImpl(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SupportRepository>()) {
      Get.lazyPut<SupportRepository>(
        () => SupportRepositoryImpl(Get.find<SupportRemoteDataSource>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SupportController>()) {
      Get.lazyPut<SupportController>(
        () => SupportController(Get.find<SupportRepository>()),
      );
    }
  }
}
