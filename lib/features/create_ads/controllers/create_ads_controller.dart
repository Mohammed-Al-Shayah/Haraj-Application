import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/features/filters/models/ad_real_estate_model.dart';

class CreateAdsController extends GetxController {
  final currentStep = 1.obs;
  final condition = AppStrings.conditionStatusNew.obs;

  final Rxn<AdType> adType = Rxn<AdType>();
  final RxnInt categoryId = RxnInt();
  final categoryTitle = ''.obs;

  final realEstateType = RealEstateType.apartments.obs;

  final Rx<AdRealEstateFilterModel> adRealEstateSpecs =
      AdRealEstateFilterModel.initialize().obs;
  final RxList<InternalFeature> internalFeatures = <InternalFeature>[].obs;
  final RxList<NearbyPlace> nearbyPlaces = <NearbyPlace>[].obs;
  final RxList<CommercialInternalFeature> commercialFeatures =
      <CommercialInternalFeature>[].obs;

  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // Images
  final ImagePicker picker = ImagePicker();
  RxList<Rx<File>> imageFiles = <Rx<File>>[].obs;

  bool _inited = false;

  void initFromArgs({
    required AdType? adTypeArg,
    required RealEstateType? initialRealEstateType,
    required int? categoryIdArg,
    required String categoryTitleArg,
  }) {
    if (_inited) return;
    _inited = true;

    adType.value = adTypeArg;
    categoryId.value = categoryIdArg;
    categoryTitle.value = categoryTitleArg;

    final rt = initialRealEstateType ?? RealEstateType.apartments;

    adRealEstateSpecs.update((m) {
      m!.realEstateType = rt;
      m.currencyId = m.currencyId ?? 1;
    });

    realEstateType.value = rt;

    debugPrint("INIT realEstateType = $rt");
    debugPrint(
      "SPEC realEstateType = ${adRealEstateSpecs.value.realEstateType}",
    );
  }

  void setRealEstateType(RealEstateType t) {
    adRealEstateSpecs.update((m) {
      m!.realEstateType = t;
    });
    realEstateType.value = t;
  }

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

  @override
  void onClose() {
    titleCtrl.dispose();
    locationCtrl.dispose();
    priceCtrl.dispose();
    descriptionCtrl.dispose();

    final m = adRealEstateSpecs.value;
    m.realEstatePartsYears?.dispose();
    m.realEstateSpace?.dispose();
    m.realEstateSpaceTo?.dispose();
    m.realEstateBathsController?.dispose();
    m.realEstateFloorsController?.dispose();
    m.realEstateRoomsController?.dispose();
    m.realEstateGardensController?.dispose();

    commercialFeatures.clear();
    internalFeatures.clear();
    nearbyPlaces.clear();

    super.onClose();
  }
}
