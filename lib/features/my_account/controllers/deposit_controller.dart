import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/features/my_account/controllers/wallet_controller.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
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
      Get.snackbar("Error", "User not found", backgroundColor: AppColors.red);
      return;
    }

    if (uploadedFile.value == null || price.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please upload an invoice and enter the amount",
        backgroundColor: AppColors.red,
      );
      return;
    }

    final amount = num.tryParse(price.value);
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Invalid amount");
      return;
    }

    isSubmitting.value = true;
    try {
      await walletController.submitDeposit(
        userId: userId,
        amount: amount,
        proofImagePath: uploadedFile.value!.path,
      );

      Get.snackbar(
        "Success",
        "Deposit request sent successfully",
        backgroundColor: AppColors.green00CD52,
      );
      uploadedFile.value = null;
      price.value = '';
    } finally {
      isSubmitting.value = false;
    }
  }
}
