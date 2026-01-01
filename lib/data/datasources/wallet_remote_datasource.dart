import 'dart:io';

import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/my_account/models/deposit_request_model.dart';
import 'package:haraj_adan_app/features/my_account/models/wallet_summary_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletSummaryModel> getWalletSummary(int userId);
  Future<DepositRequestModel> createDepositRequest({
    required int userId,
    required num amount,
    required File proofImage,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl(this.apiClient);

  @override
  Future<WalletSummaryModel> getWalletSummary(int userId) async {
    final res = await apiClient.get('${ApiEndpoints.walletSummary}/$userId');
    return WalletSummaryModel.fromJson(res);
  }

  @override
  Future<DepositRequestModel> createDepositRequest({
    required int userId,
    required num amount,
    required File proofImage,
  }) async {
    final fileName = proofImage.path.split(RegExp(r'[\\/]+')).last;

    final formData = FormData.fromMap({
      'amount': amount,
      'user_id': userId,
      'proof_image': await MultipartFile.fromFile(
        proofImage.path,
        filename: fileName,
      ),
    });

    final res = await apiClient.post(
      ApiEndpoints.walletDepositRequest,
      data: formData,
      isMultipart: true,
    );

    return DepositRequestModel.fromJson(res);
  }
}
