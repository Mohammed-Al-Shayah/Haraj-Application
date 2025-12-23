import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';

class CreateAdsController extends GetxController {
  final currentStep = 1.obs;
  final condition = AppStrings.conditionStatusNew.obs;

  final ImagePicker picker = ImagePicker();
  RxList<Rx<File>> imageFiles = <Rx<File>>[].obs;

  void goToNextStep() {
    if (currentStep.value < 2) {
      currentStep.value += 1;
    } else {
      Get.offNamed(Routes.successPostedScreen);
    }
  }

  void goToPreviousStep() {
    if (currentStep.value > 1) {
      currentStep.value -= 1;
    } else {
      Get.back();
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFiles.add(File(pickedFile.path).obs);
    }
  }
}
