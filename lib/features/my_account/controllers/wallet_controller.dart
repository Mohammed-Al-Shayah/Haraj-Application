import 'package:get/get.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/domain/entities/wallet_summary_entity.dart';
import 'package:haraj_adan_app/domain/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository repo;
  WalletController(this.repo);

  final isLoading = false.obs;
  final isSubmittingDeposit = false.obs;

  final summary = Rxn<WalletSummaryEntity>();

  
  @override
  void onInit() {
    super.onInit();
    _init();
  }

    Future<void> _init() async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) return;
    await fetchSummary(userId);
  }

  Future<void> fetchSummary(int userId) async {
    isLoading.value = true;
    try {
      summary.value = await repo.getWalletSummary(userId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitDeposit({
    required int userId,
    required num amount,
    required String proofImagePath,
  }) async {
    isSubmittingDeposit.value = true;
    try {
      await repo.createDepositRequest(
        userId: userId,
        amount: amount,
        proofImagePath: proofImagePath,
      );
      await fetchSummary(userId);
    } finally {
      isSubmittingDeposit.value = false;
    }
  }
}
