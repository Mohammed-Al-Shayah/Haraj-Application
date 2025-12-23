import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/my_account/controllers/wallet_controller.dart';

class TransactionHistoryContent extends StatelessWidget {
  const TransactionHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.transactionHistory, style: AppTypography.semiBold18),
          const SizedBox(height: 12),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary = controller.summary.value;
            final txs = summary?.lastTransactions ?? [];

            if (txs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: AppTypography.normal14,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: txs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final t = txs[index];

                final isCredit = t.typeCode.toLowerCase() == 'credit';
                final amountText = (isCredit ? '-' : '+') + t.amount;

                final statusCode = t.statusCode.toUpperCase();
                final statusColor =
                    statusCode == 'COMPLETED'
                        ? Colors.green
                        : statusCode == 'PENDING'
                        ? Colors.orange
                        : Colors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.descr, style: AppTypography.semiBold14),
                          const SizedBox(height: 4),
                          Text(
                            t.created.toString(),
                            style: AppTypography.normal12.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            amountText,
                            style: AppTypography.medium12.copyWith(
                              color: isCredit ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusCode,
                              style: AppTypography.medium10.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
