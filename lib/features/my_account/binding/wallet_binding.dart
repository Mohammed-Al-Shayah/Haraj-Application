import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/data/datasources/wallet_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/wallet_repository_impl.dart';
import 'package:haraj_adan_app/domain/repositories/wallet_repository.dart';
import 'package:haraj_adan_app/features/my_account/controllers/deposit_controller.dart';
import 'package:haraj_adan_app/features/my_account/controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(client: Dio()));
    }

    Get.lazyPut<WalletRemoteDataSource>(
      () => WalletRemoteDataSourceImpl(Get.find<ApiClient>()),
    );

    Get.lazyPut<WalletRepository>(
      () => WalletRepositoryImpl(Get.find<WalletRemoteDataSource>()),
    );

    Get.lazyPut(() => WalletController(Get.find<WalletRepository>()));

    Get.lazyPut(() => DepositController());
  }
}
