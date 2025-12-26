import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/filters/controllers/filter_controller.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/features/filters/views/screens/filter_template.dart';
import 'package:haraj_adan_app/features/filters/views/screens/vehicle_filter.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/from_to_field.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/select_items.dart';
import '../../models/ad_real_estate_model.dart';

class RealEstateFilter extends StatefulWidget {
  const RealEstateFilter({
    super.key,
    this.initialType,
    required this.categoryId,
    required this.categoryTitle,
    required this.adType,
  });

  final RealEstateType? initialType;
  final int categoryId;
  final String categoryTitle;
  final AdType adType;

  @override
  State<RealEstateFilter> createState() => _RealEstateFilterState();
}

class _RealEstateFilterState extends State<RealEstateFilter> {
  late FilterController controller;

  @override
  void initState() {
    controller = Get.put(
      FilterController(
        AdType.real_estates,
        initialRealEstateType: widget.initialType,
      ),
      tag: "real_estates",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height - 100;
    return SizedBox(
      height: availableHeight,
      child: Obx(() {
        return FilterTemplate(
          onApplyFilter: () {
            Get.back(); // close bottom sheet
            Get.toNamed(
              Routes.postAdScreen,
              arguments: {
                'categoryId': widget.categoryId,
                'categoryTitle': widget.categoryTitle,
                'adType': widget.adType,
              },
            );
          },
          onResetFilter: () {
            controller.adRealEstate.value =
                AdRealEstateFilterModel.initialize();
            controller.adRealEstate.value.realEstateType =
                widget.initialType ?? RealEstateType.apartments;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                key: controller.columnKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DropdownButtonWidget(
                  //   selectedItem: AdType.real_estates,
                  //   items: [
                  //     DropdownButtonModel(
                  //       dropValue: AdType.real_estates,
                  //       dropText: AdType.real_estates.name.tr(),
                  //     ),
                  //   ],
                  //   title: AppStrings.category,
                  // ),
                  // const Space(),
                  // SelectItemsWidget<RealEstateType>(
                  //   title: AppStrings.realEstateType,
                  //   items: RealEstateType.values,
                  //   onChanged: (v) {
                  //     controller.adRealEstate.update((val) {
                  //       if (val!.realEstateType! != v) {
                  //         val.realEstateType = v;
                  //       }
                  //     });
                  //   },
                  //   selectedItems: [
                  //     controller.adRealEstate.value.realEstateTسype!,
                  //   ],
                  // ),
                  // const Space(),
                  SelectItemsWidget<AdCategory>(
                    title: AppStrings.adType,
                    items: AdCategory.values,
                    onChanged: (v) {
                      controller.adRealEstate.update((val) {
                        if (!val!.adCategory!.contains(v)) {
                          val.adCategory!.clear();
                          val.adCategory!.add(v!);
                        }
                      });
                    },
                    selectedItems: controller.adRealEstate.value.adCategory!,
                  ),
                  if (controller.adRealEstate.value.realEstateType ==
                      RealEstateType.lands) ...[
                    SelectItemsWidget<GroundSystem>(
                      title: AppStrings.groundSystem,
                      items: GroundSystem.values,
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          if (!val!.groundSystem!.contains(v)) {
                            val.groundSystem!.clear();
                            val.groundSystem!.add(v!);
                          }
                        });
                      },
                      selectedItems:
                          controller.adRealEstate.value.groundSystem!,
                    ),
                    const Space(),
                  ],
                  const Space(),
                  if ([
                    RealEstateType.buildings,
                    RealEstateType.houses,
                  ].contains(controller.adRealEstate.value.realEstateType)) ...[
                    SelectItemsWidget<int>(
                      textFieldLabel:
                          controller.adRealEstate.value.realEstateType ==
                                  RealEstateType.buildings
                              ? "${AppStrings.more}: "
                              : null,
                      controller:
                          controller
                              .adRealEstate
                              .value
                              .realEstateFloorsController,
                      onTextChanged: (v) {
                        controller.adRealEstate.update((val) {
                          int? value = int.tryParse(v!);
                          if (value == null) return;
                          val!.realEstateFloors = value;
                        });
                      },
                      title: AppStrings.floorCount,
                      items: [
                        1,
                        2,
                        3,
                        if (controller.adRealEstate.value.realEstateType ==
                            RealEstateType.buildings) ...[
                          4,
                          5,
                          6,
                        ],
                      ],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateFloors = v;
                          val.realEstateFloorsController?.text = "";
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateFloors!,
                      ],
                    ),
                    const Space(),
                    SelectItemsWidget<RealEstateFinishing>(
                      title: AppStrings.finishingType,
                      items: RealEstateFinishing.values,
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          if (!val!.realEstateFinishing!.contains(v)) {
                            val.realEstateFinishing!.clear();
                            val.realEstateFinishing!.add(v!);
                          }
                        });
                      },
                      selectedItems:
                          controller.adRealEstate.value.realEstateFinishing!,
                    ),
                    const Space(),
                  ],
                  if ([
                    RealEstateType.apartments,
                    RealEstateType.houses,
                  ].contains(controller.adRealEstate.value.realEstateType)) ...[
                    SelectItemsWidget<RealEstateFurnitureType>(
                      title: AppStrings.furnetureType,
                      items: RealEstateFurnitureType.values,
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          if (!val!.realEstateFurnitureType!.contains(v)) {
                            val.realEstateFurnitureType!.clear();
                            val.realEstateFurnitureType!.add(v!);
                          }
                        });
                      },
                      selectedItems:
                          controller
                              .adRealEstate
                              .value
                              .realEstateFurnitureType!,
                    ),
                    const Space(),
                  ],
                  if (![
                    RealEstateType.buildings,
                    RealEstateType.lands,
                  ].contains(controller.adRealEstate.value.realEstateType)) ...[
                    SelectItemsWidget<int>(
                      textFieldLabel: "${AppStrings.more}: ",
                      controller:
                          controller
                              .adRealEstate
                              .value
                              .realEstateRoomsController,
                      onTextChanged: (v) {
                        controller.adRealEstate.update((val) {
                          int? value = int.tryParse(v!);
                          if (value == null) return;
                          val!.realEstateRooms = value;
                        });
                      },
                      title: AppStrings.roomCount,
                      items: const [1, 2, 3, 4, 5, 6],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateRooms = v;
                          val.realEstateRoomsController?.text = "";
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateRooms!,
                      ],
                    ),
                    const Space(),
                  ],
                  SelectItemsWidget<PaySystem>(
                    controller:
                        controller.adRealEstate.value.realEstatePartsYears!,
                    textFieldLabel:
                        controller.adRealEstate.value.paySystem ==
                                PaySystem.cash
                            ? null
                            : "${AppStrings.yearCount}: ",
                    title: AppStrings.paySystem,
                    items: PaySystem.values,
                    onChanged: (v) {
                      controller.adRealEstate.update((val) {
                        val!.paySystem = v;
                      });
                    },
                    selectedItems: [controller.adRealEstate.value.paySystem!],
                  ),
                  const Space(),
                  if (controller.adRealEstate.value.realEstateType !=
                      RealEstateType.apartments) ...[
                    FromToField(
                      title: AppStrings.space,
                      from: controller.adRealEstate.value.realEstateSpace!,
                      to: controller.adRealEstate.value.realEstateSpaceTo!,
                    ),
                    const Space(),
                  ],
                  if (controller.adRealEstate.value.realEstateType ==
                      RealEstateType.lands) ...[
                    SelectItemsWidget<int>(
                      title: AppStrings.aroundStreets,
                      items: const [0, 1, 2, 3, 4],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          if (val!.streetsAroundCount!.contains(v!)) {
                            val.streetsAroundCount!.remove(v);
                          } else {
                            val.streetsAroundCount!.add(v);
                          }
                        });
                      },
                      selectedItems:
                          controller.adRealEstate.value.streetsAroundCount!,
                    ),
                    const Space(),
                  ],
                  if (![
                    RealEstateType.buildings,
                    RealEstateType.lands,
                  ].contains(controller.adRealEstate.value.realEstateType)) ...[
                    SelectItemsWidget<int>(
                      textFieldLabel: "${AppStrings.more}: ",
                      controller:
                          controller
                              .adRealEstate
                              .value
                              .realEstateBathsController,
                      onTextChanged: (v) {
                        controller.adRealEstate.update((val) {
                          int? value = int.tryParse(v!);
                          if (value == null) return;
                          val!.realEstateBaths = value;
                        });
                      },
                      title: AppStrings.bathroomCount,
                      items: const [1, 2, 3, 4],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateBaths = v;
                          val.realEstateBathsController?.text = "";
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateBaths!,
                      ],
                    ),
                    const Space(),
                  ],
                  if (controller.adRealEstate.value.realEstateType ==
                      RealEstateType.villas) ...[
                    SelectItemsWidget<int>(
                      textFieldLabel: "${AppStrings.more}: ",
                      controller:
                          controller
                              .adRealEstate
                              .value
                              .realEstateGardensController,
                      onTextChanged: (v) {
                        controller.adRealEstate.update((val) {
                          int? value = int.tryParse(v!);
                          if (value == null) return;
                          val!.realEstateGardens = value;
                        });
                      },
                      title: AppStrings.gardenCount,
                      items: const [0, 1, 2, 3, 4],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateGardens = v;
                          val.realEstateGardensController?.text = "";
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateGardens!,
                      ],
                    ),
                    const Space(),
                    SelectItemsWidget<String>(
                      title: AppStrings.bool,
                      items: [AppStrings.yes, AppStrings.no],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateHasBool = v == AppStrings.yes;
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateHasBool!
                            ? AppStrings.yes
                            : AppStrings.no,
                      ],
                    ),
                    const Space(),
                  ],
                  if (controller.adRealEstate.value.realEstateType ==
                      RealEstateType.apartments) ...[
                    SelectItemsWidget<String>(
                      title: AppStrings.shareApartment,
                      items: [AppStrings.yes, AppStrings.no],
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          val!.realEstateSharing = v == AppStrings.yes;
                        });
                      },
                      selectedItems: [
                        controller.adRealEstate.value.realEstateSharing!
                            ? AppStrings.yes
                            : AppStrings.no,
                      ],
                    ),
                    const Space(),
                  ],
                  if (controller.adRealEstate.value.realEstateType ==
                      RealEstateType.buildings) ...[
                    SelectItemsWidget<RealEstateBuilding>(
                      title: AppStrings.building,
                      items: RealEstateBuilding.values,
                      onChanged: (v) {
                        controller.adRealEstate.update((val) {
                          if (!val!.realEstateBuilding!.contains(v)) {
                            val.realEstateBuilding!.clear();
                            val.realEstateBuilding!.add(v!);
                          }
                        });
                      },
                      selectedItems:
                          controller.adRealEstate.value.realEstateBuilding!,
                    ),
                    const Space(),
                  ],
                  SelectItemsWidget(
                    title: AppStrings.currency,
                    items: const [],
                    onChanged: (v) {
                      // controller.adVehicle.update((val){
                      //    val.currencyId = v;
                      // });
                    },
                    selectedItems: [controller.adRealEstate.value.currencyId],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
