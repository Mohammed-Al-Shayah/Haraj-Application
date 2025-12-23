import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

class AdVehicleFilterModel {
  List<VehicleType>? vehicleType;
  List<AdCategory>? adCategory;
  AdElementState? adElementState;
  TextEditingController? vehicleWalkedByKilo;
  TextEditingController? vehicleWalkedByKiloTo;
  TextEditingController? vehicleMadeYear;
  TextEditingController? vehicleMadeYearTo;
  String? vehicleMachine;
  JerType? vehicleJerType;
  List<int>? vehiclePostNumber;
  List<FuelType>? vehicleFuelType;
  PaySystem? paySystem;
  TextEditingController? vehiclePartsYears;
  int? companyId;
  int? carTypeId;
  int? currencyId;
  AdVehicleFilterModel({
    this.vehicleType,
    this.adCategory,
    this.adElementState,
    this.vehicleWalkedByKilo,
    this.vehicleWalkedByKiloTo,
    this.vehicleMadeYear,
    this.vehicleMadeYearTo,
    this.vehicleMachine,
    this.vehicleJerType,
    this.vehiclePostNumber,
    this.vehicleFuelType,
    this.paySystem,
    this.vehiclePartsYears,
    this.companyId,
    this.carTypeId,
    this.currencyId,
  });

  factory AdVehicleFilterModel.initialize({
    List<VehicleType>? vehicleType,
    List<AdCategory>? adCategory,
    AdElementState? adElementState,
    String? vehicleWalkedByKilo,
    String? vehicleWalkedByKiloTo,
    String? vehicleMadeYear,
    String? vehicleMadeYearTo,
    String? vehicleMachine,
    JerType? vehicleJerType,
    List<int>? vehiclePostNumber,
    List<FuelType>? vehicleFuelType,
    PaySystem? paySystem,
    String? vehiclePartsYears,
    int? companyId,
    int? carTypeId,
    int? currencyId,
  }) {
    return AdVehicleFilterModel(
      vehicleType: vehicleType ?? [VehicleType.car],
      adCategory: adCategory ?? [AdCategory.sell],
      adElementState: adElementState ?? AdElementState.New,
      vehicleWalkedByKilo:
          TextEditingController(text: vehicleWalkedByKilo ?? ""),
      vehicleWalkedByKiloTo:
          TextEditingController(text: vehicleWalkedByKiloTo ?? ""),
      vehicleMadeYear: TextEditingController(text: vehicleMadeYear ?? ""),
      vehicleMadeYearTo: TextEditingController(text: vehicleMadeYearTo ?? ""),
      vehicleMachine: vehicleMachine ?? "1.3",
      vehicleJerType: vehicleJerType ?? JerType.automatic,
      vehiclePostNumber: vehiclePostNumber ?? [3],
      vehicleFuelType: vehicleFuelType ?? [FuelType.gasoline],
      paySystem: paySystem ?? PaySystem.cash,
      vehiclePartsYears: TextEditingController(text: vehiclePartsYears ?? ""),
      companyId: companyId,
      carTypeId: carTypeId,
      currencyId: currencyId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vehicleType': vehicleType,
      'adCategory': adCategory,
      'adElementState': adElementState?.name,
      'vehicleWalkedByKilo': vehicleWalkedByKilo?.text,
      'vehicleWalkedByKiloTo': vehicleWalkedByKiloTo?.text,
      'vehicleMadeYear': vehicleMadeYear?.text,
      'vehicleMadeYearTo': vehicleMadeYearTo?.text,
      'vehicleMachine': vehicleMachine,
      'vehicleJerType': vehicleJerType,
      'vehiclePostNumber': vehiclePostNumber,
      'vehicleFuelType': vehicleFuelType,
      'paySystem': paySystem?.name,
      'vehiclePartsYears': vehiclePartsYears?.text,
      'companyId': companyId,
      'carTypeId': carTypeId,
      'currencyId': currencyId,
    };
  }

  String toJson() => json.encode(toMap());
}

