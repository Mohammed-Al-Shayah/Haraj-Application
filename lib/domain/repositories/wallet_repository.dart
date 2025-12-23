import 'package:haraj_adan_app/domain/entities/deposit_request_entity.dart';
import 'package:haraj_adan_app/domain/entities/wallet_summary_entity.dart';

abstract class WalletRepository {
  Future<WalletSummaryEntity> getWalletSummary(int userId);
  Future<DepositRequestEntity> createDepositRequest({
    required int userId,
    required num amount,
    required String proofImagePath,
  });
}
