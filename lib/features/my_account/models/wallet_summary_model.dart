
import 'package:haraj_adan_app/domain/entities/wallet_summary_entity.dart';
import 'package:haraj_adan_app/features/my_account/models/wallet_transaction_model.dart';

class WalletSummaryModel {
  final String balance;
  final List<WalletTransactionModel> lastTransactions;

  WalletSummaryModel({
    required this.balance,
    required this.lastTransactions,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return WalletSummaryModel(
      balance: (data['balance'] ?? '').toString(),
      lastTransactions: (data['lastTransactions'] as List? ?? [])
          .map((e) => WalletTransactionModel.fromJson(e))
          .toList(),
    );
  }

  WalletSummaryEntity toEntity() => WalletSummaryEntity(
        balance: balance,
        lastTransactions: lastTransactions.map((e) => e.toEntity()).toList(),
      );
}
