import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/deposit_content.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/transaction_history_content.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/wallet_header.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.wallet,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WalletHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DepositContent(),
                  SizedBox(height: 20),
                  TransactionHistoryContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
