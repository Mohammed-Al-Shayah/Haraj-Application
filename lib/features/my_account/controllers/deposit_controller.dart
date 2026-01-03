import 'package:haraj_adan_app/features/my_account/controllers/wallet_controller.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'dart:io';

class DepositController extends GetxController {
  final WalletController walletController = Get.find<WalletController>();

  Rx<File?> uploadedFile = Rx<File?>(null);
  RxString price = ''.obs;
  RxBool isSubmitting = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      uploadedFile.value = File(picked.path);
    }
  }

  void updatePrice(String value) {
    price.value = value;
  }

  Future<void> submit() async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.userNotFound);
      return;
    }

    if (uploadedFile.value == null || price.value.isEmpty) {
      AppSnack.error(
        AppStrings.errorTitle,
        AppStrings.depositInvoiceAndAmountRequired,
      );
      return;
    }

    final amount = num.tryParse(price.value);
    if (amount == null || amount <= 0) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.depositInvalidAmount);
      return;
    }

    isSubmitting.value = true;
    try {
      await walletController.submitDeposit(
        userId: userId,
        amount: amount,
        proofImagePath: uploadedFile.value!.path,
      );

      AppSnack.success(
        AppStrings.successTitle,
        AppStrings.depositRequestSuccess,
      );
      uploadedFile.value = null;
      price.value = '';
    } finally {
      isSubmitting.value = false;
    }
  }
}
