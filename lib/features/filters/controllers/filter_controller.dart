import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/filters/models/ad_real_estate_model.dart';
import 'package:haraj_adan_app/features/filters/models/ad_vehicle_model.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

class FilterController extends GetxController{
  AdType type;
  final RealEstateType? initialRealEstateType;
  late Rx<AdVehicleFilterModel> adVehicle; 
  late Rx<AdRealEstateFilterModel> adRealEstate;
  GlobalKey columnKey = GlobalKey();
  FilterController(this.type, {this.initialRealEstateType});

  @override
  void onInit() {
    if(type == AdType.vehicles){
      adVehicle = AdVehicleFilterModel.initialize().obs;
    }
    if(type == AdType.real_estates){
      adRealEstate = AdRealEstateFilterModel.initialize().obs;
      adRealEstate.value.realEstateType =
          initialRealEstateType ?? RealEstateType.apartments;
    }
    super.onInit();
  }
}
