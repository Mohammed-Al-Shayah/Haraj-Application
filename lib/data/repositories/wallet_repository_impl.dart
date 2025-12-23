import 'dart:io';

import 'package:haraj_adan_app/data/datasources/wallet_remote_datasource.dart';
import 'package:haraj_adan_app/domain/entities/deposit_request_entity.dart';
import 'package:haraj_adan_app/domain/entities/wallet_summary_entity.dart';
import 'package:haraj_adan_app/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remote;

  WalletRepositoryImpl(this.remote);

  @override
  Future<WalletSummaryEntity> getWalletSummary(int userId) async {
    final model = await remote.getWalletSummary(userId);
    return model.toEntity();
  }

  @override
  Future<DepositRequestEntity> createDepositRequest({
    required int userId,
    required num amount,
    required String proofImagePath,
  }) async {
    final model = await remote.createDepositRequest(
      userId: userId,
      amount: amount,
      proofImage: File(proofImagePath),
    );
    return model.toEntity();
  }
}
