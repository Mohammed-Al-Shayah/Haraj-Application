import 'package:haraj_adan_app/domain/entities/wallet_transaction_entity.dart';

class WalletSummaryEntity {
  final String balance;
  final List<WalletTransactionEntity> lastTransactions;

  const WalletSummaryEntity({
    required this.balance,
    required this.lastTransactions,
  });
}
