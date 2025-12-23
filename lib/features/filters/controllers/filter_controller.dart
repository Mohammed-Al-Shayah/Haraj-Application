import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/filters/models/ad_real_estate_model.dart';
import 'package:haraj_adan_app/features/filters/models/ad_vehicle_model.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

class FilterController extends GetxController{
  AdType type;
  late Rx<AdVehicleFilterModel> adVehicle; 
  late Rx<AdRealEstateFilterModel> adRealEstate;
  GlobalKey columnKey = GlobalKey();
  late RxDouble bottomSheetHeight;
  FilterController(this.type);
  @override
  void onInit() {
    if(type == AdType.vehicles){
      adVehicle = AdVehicleFilterModel.initialize().obs;
    }
    if(type == AdType.real_estates){
      bottomSheetHeight = (300.0).obs;
      adRealEstate = AdRealEstateFilterModel.initialize().obs;
      adRealEstate.value.realEstateType = RealEstateType.apartments;
    }
    super.onInit();
  }

  void changeHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bottomSheetHeight.value = columnKey.currentContext!.size!.height + 200;
    });
  }
}