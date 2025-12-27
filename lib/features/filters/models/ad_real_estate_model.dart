import 'package:flutter/cupertino.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

class AdRealEstateFilterModel {
  List<AdCategory>? adCategory;
  PaySystem? paySystem;
  TextEditingController? realEstatePartsYears;
  RealEstateType? realEstateType;
  TextEditingController? realEstateSpace;
  TextEditingController? realEstateSpaceTo;
  TextEditingController? realEstateBathsController;
  int? realEstateBaths;
  TextEditingController? realEstateFloorsController;
  int? realEstateFloors;
  bool? realEstateSharing;
  bool? realEstateHasBool;
  TextEditingController? realEstateRoomsController;
  int? realEstateRooms;
  TextEditingController? realEstateGardensController;
  int? realEstateGardens;
  List<RealEstateFurnitureType>? realEstateFurnitureType;
  List<RealEstateBuilding>? realEstateBuilding;
  List<RealEstateFinishing>? realEstateFinishing;
  List<GroundSystem>? groundSystem;
  BuildingAge? buildingAge;
  ShopOpenings? shopOpenings;
  List<ApartmentFeature>? apartmentFeatures;
  CommercialCategory? commercialCategory;
  bool? businessActive;
  bool? readyForWork;
  CommercialOwnerType? commercialOwnerType;
  List<CommercialInternalFeature>? commercialInternalFeatures;
  List<int>? streetsAroundCount;
  int? currencyId;

  AdRealEstateFilterModel({
    this.adCategory,
    this.paySystem,
    this.realEstatePartsYears,
    this.realEstateType,
    this.realEstateSpace,
    this.realEstateSpaceTo,
    this.realEstateBathsController,
    this.realEstateBaths,
    this.realEstateFloorsController,
    this.realEstateFloors,
    this.realEstateSharing,
    this.realEstateHasBool,
    this.realEstateRoomsController,
    this.realEstateRooms,
    this.realEstateGardensController,
    this.realEstateGardens,
    this.realEstateFurnitureType,
    this.realEstateBuilding,
    this.realEstateFinishing,
    this.groundSystem,
    this.buildingAge,
    this.shopOpenings,
    this.apartmentFeatures,
    this.commercialCategory,
    this.businessActive,
    this.readyForWork,
    this.commercialOwnerType,
    this.commercialInternalFeatures,
    this.streetsAroundCount,
    this.currencyId,
  });

  factory AdRealEstateFilterModel.initialize({
    List<AdCategory>? adCategory,
    PaySystem? paySystem,
    String? realEstatePartsYears,
    RealEstateType? realEstateType,
    String? realEstateSpace,
    String? realEstateSpaceTo,
    String? realEstateBathsController,
    int? realEstateBaths,
    String? realEstateFloorsController,
    int? realEstateFloors,
    bool? realEstateSharing,
    bool? realEstateHasBool,
    String? realEstateRoomsController,
    int? realEstateRooms,
    String? realEstateGardensController,
    int? realEstateGardens,
    List<RealEstateFurnitureType>? realEstateFurnitureType,
    List<RealEstateBuilding>? realEstateBuilding,
    List<RealEstateFinishing>? realEstateFinishing,
    List<GroundSystem>? groundSystem,
    BuildingAge? buildingAge,
    ShopOpenings? shopOpenings,
    List<ApartmentFeature>? apartmentFeatures,
    CommercialCategory? commercialCategory,
    bool? businessActive,
    bool? readyForWork,
    CommercialOwnerType? commercialOwnerType,
    List<CommercialInternalFeature>? commercialInternalFeatures,
    List<int>? streetsAroundCount,
    int? currencyId,
  }) {
    return AdRealEstateFilterModel(
      adCategory: adCategory ?? [AdCategory.sell],
      paySystem: paySystem ?? PaySystem.cash,
      realEstatePartsYears:
          TextEditingController(text: realEstatePartsYears ?? ""),
      realEstateSpace: TextEditingController(text: realEstateSpace ?? ""),
      realEstateSpaceTo: TextEditingController(text: realEstateSpaceTo ?? ""),
      realEstateBathsController:
          TextEditingController(text: realEstateBathsController ?? ""),
      realEstateBaths: realEstateBaths ?? 1,
      realEstateFloorsController:
          TextEditingController(text: realEstateFloorsController ?? ""),
      realEstateFloors: realEstateFloors ?? 1,
      realEstateSharing: realEstateSharing ?? true,
      realEstateHasBool: realEstateHasBool ?? true,
      realEstateRoomsController:
          TextEditingController(text: realEstateRoomsController ?? ""),
      realEstateRooms: realEstateRooms ?? 1,
      realEstateGardensController:
          TextEditingController(text: realEstateGardensController ?? ""),
      realEstateGardens: realEstateGardens ?? 0,
      realEstateFurnitureType:
          realEstateFurnitureType ?? [RealEstateFurnitureType.yes],
      realEstateBuilding: realEstateBuilding ?? [RealEstateBuilding.busnies],
      realEstateFinishing:
          realEstateFinishing ?? [RealEstateFinishing.full_finishing],
      groundSystem: groundSystem ?? [GroundSystem.residential],
      buildingAge: buildingAge ?? BuildingAge.lessThan5,
      shopOpenings: shopOpenings ?? ShopOpenings.one,
      apartmentFeatures: apartmentFeatures ?? [],
      commercialCategory: commercialCategory ?? CommercialCategory.multiUnits,
      businessActive: businessActive ?? true,
      readyForWork: readyForWork ?? true,
      commercialOwnerType:
          commercialOwnerType ?? CommercialOwnerType.owner,
      commercialInternalFeatures:
          commercialInternalFeatures ?? [],
      streetsAroundCount: streetsAroundCount ?? [0],
      currencyId: currencyId,
    );
  }
}
