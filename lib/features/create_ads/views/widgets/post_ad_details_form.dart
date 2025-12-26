import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/condition_status.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/from_to_field.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/select_items.dart';

class PostAdDetailsForm extends StatelessWidget {
  const PostAdDetailsForm({
    super.key,
    required this.controller,
    this.adType,
    this.categoryId,
    this.categoryTitle,
  });

  final CreateAdsController controller;
  final AdType? adType;
  final int? categoryId;
  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info
        InputField(
          controller: controller.titleCtrl,
          keyboardType: TextInputType.text,
          labelText: AppStrings.adNameText,
          hintText: AppStrings.adNameHint,
        ),
        const SizedBox(height: 20),
        InputField(
          controller: controller.locationCtrl,
          keyboardType: TextInputType.text,
          labelText: AppStrings.locationText,
          hintText: AppStrings.locationText,
        ),
        const SizedBox(height: 20),
        InputField(
          controller: controller.priceCtrl,
          keyboardType: TextInputType.number,
          labelText: AppStrings.priceText,
          hintText: AppStrings.priceText,
        ),
        const SizedBox(height: 20),
        InputField(
          controller: controller.descriptionCtrl,
          keyboardType: TextInputType.text,
          labelText: AppStrings.descriptionText,
          hintText: AppStrings.descriptionHint,
          maxLines: 5,
        ),
        const SizedBox(height: 15),
        ConditionStatus(controller: controller),
        const SizedBox(height: 20),
        Obx(() {
          return SelectItemsWidget<CurrencyOption>(
            title: AppStrings.currency,
            items: CurrencyOption.values,
            onChanged: (v) {
              controller.adRealEstateSpecs.update((val) {
                if (v == null) return;
                val!.currencyId = v.index;
              });
            },
            selectedItems: [
              CurrencyOption.values[controller
                      .adRealEstateSpecs
                      .value
                      .currencyId ??
                  CurrencyOption.rialYemeni.index],
            ],
          );
        }),
        const SizedBox(height: 15),
        if (adType == AdType.vehicles) ...[
          _VehicleSpecs(controller: controller),
          const SizedBox(height: 20),
        ],
        if (adType == AdType.real_estates) ...[
          _RealEstateSpecs(controller: controller),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _VehicleSpecs extends StatelessWidget {
  const _VehicleSpecs({required this.controller});
  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // children: [
      //   Obx(() {
      //     return SelectItemsWidget<VehicleType>(
      //       title: AppStrings.theType,
      //       items: VehicleType.values,
      //       onChanged: (v) {
      //         if (v != null) controller.vehicleType.value = v;
      //       },
      //       selectedItems: [controller.vehicleType.value],
      //     );
      //   }),
      //   const SizedBox(height: 20),

      //   Obx(() {
      //     return SelectItemsWidget<AdCategory>(
      //       title: AppStrings.adType,
      //       items: AdCategory.values,
      //       onChanged: (v) {
      //         if (v != null) controller.adCategory.value = v;
      //       },
      //       selectedItems: [controller.adCategory.value],
      //     );
      //   }),
      //   const SizedBox(height: 20),

      //   FromToField(
      //     title: AppStrings.wolked,
      //     from: controller.vehicleWalkedKilo,
      //     to: TextEditingController(),
      //   ),
      //   const SizedBox(height: 20),

      //   FromToField(
      //     title: AppStrings.yearMade,
      //     from: controller.vehicleMadeYear,
      //     to: TextEditingController(),
      //   ),
      //   const SizedBox(height: 20),

      //   Obx(() {
      //     return SelectItemsWidget<String>(
      //       title: AppStrings.machine,
      //       items: const ["1.3", "1.6", "1.9"],
      //       onChanged: (v) {
      //         if (v != null) controller.vehicleMachine.value = v;
      //       },
      //       selectedItems: [controller.vehicleMachine.value],
      //     );
      //   }),
      //   const SizedBox(height: 20),

      //   Obx(() {
      //     return SelectItemsWidget<JerType>(
      //       title: AppStrings.jerType,
      //       items: JerType.values,
      //       onChanged: (v) {
      //         if (v != null) controller.vehicleJerType.value = v;
      //       },
      //       selectedItems: [controller.vehicleJerType.value],
      //     );
      //   }),
      //   const SizedBox(height: 20),

      //   Obx(() {
      //     return SelectItemsWidget<FuelType>(
      //       title: AppStrings.fuelType,
      //       items: FuelType.values,
      //       onChanged: (v) {
      //         if (v == null) return;
      //         if (controller.vehicleFuelTypes.contains(v)) {
      //           controller.vehicleFuelTypes.remove(v);
      //         } else {
      //           controller.vehicleFuelTypes.add(v);
      //         }
      //       },
      //       selectedItems: controller.vehicleFuelTypes.toList(),
      //     );
      //   }),
      // ],
    );
  }
}

class _RealEstateSpecs extends StatelessWidget {
  const _RealEstateSpecs({required this.controller});

  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final specs = controller.adRealEstateSpecs.value;
      final type = controller.adRealEstateSpecs.value.realEstateType;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectItemsWidget<AdCategory>(
            title: AppStrings.adType,
            items: AdCategory.values,
            onChanged: (v) {
              if (v == null) return;
              controller.adRealEstateSpecs.update((val) {
                if (!val!.adCategory!.contains(v)) {
                  val.adCategory!.clear();
                  val.adCategory!.add(v);
                }
              });
            },
            selectedItems: specs.adCategory!,
          ),
          const SizedBox(height: 20),
          if (type == RealEstateType.lands) ...[
            SelectItemsWidget<GroundSystem>(
              title: AppStrings.groundSystem,
              items: GroundSystem.values,
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  if (!val!.groundSystem!.contains(v)) {
                    val.groundSystem!.clear();
                    val.groundSystem!.add(v);
                  }
                });
              },
              selectedItems: specs.groundSystem!,
            ),
            const SizedBox(height: 20),
          ],

          if ([
            RealEstateType.buildings,
            RealEstateType.houses,
          ].contains(type)) ...[
            Obx(() {
              return SelectItemsWidget<BuildingAge>(
                title: AppStrings.buildingAge,
                items: BuildingAge.values,
                onChanged: (v) {
                  if (v == null) return;
                  controller.adRealEstateSpecs.update((val) {
                    val!.buildingAge = v;
                  });
                },
                selectedItems: [
                  controller.adRealEstateSpecs.value.buildingAge ??
                      BuildingAge.lessThan5,
                ],
              );
            }),
            const SizedBox(height: 20),
            SelectItemsWidget<int>(
              textFieldLabel:
                  type == RealEstateType.buildings
                      ? "${AppStrings.more}: "
                      : null,
              controller: specs.realEstateFloorsController,
              onTextChanged: (v) {
                final value = int.tryParse((v ?? '').trim());
                if (value == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateFloors = value;
                });
              },
              title: AppStrings.floorCount,
              items: [
                1,
                2,
                3,
                if (type == RealEstateType.buildings) ...[4, 5, 6],
              ],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateFloors = v;
                  val.realEstateFloorsController?.text = "";
                });
              },
              selectedItems: [specs.realEstateFloors ?? 1],
            ),
            const SizedBox(height: 20),

            SelectItemsWidget<RealEstateFinishing>(
              title: AppStrings.finishingType,
              items: RealEstateFinishing.values,
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  if (!val!.realEstateFinishing!.contains(v)) {
                    val.realEstateFinishing!.clear();
                    val.realEstateFinishing!.add(v);
                  }
                });
              },
              selectedItems: specs.realEstateFinishing!,
            ),
            const SizedBox(height: 20),
          ],

          // ✅ شقق + بيوت
          if ([
            RealEstateType.apartments,
            RealEstateType.houses,
          ].contains(type)) ...[
            SelectItemsWidget<RealEstateFurnitureType>(
              title: AppStrings.furnetureType,
              items: RealEstateFurnitureType.values,
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  if (!val!.realEstateFurnitureType!.contains(v)) {
                    val.realEstateFurnitureType!.clear();
                    val.realEstateFurnitureType!.add(v);
                  }
                });
              },
              selectedItems: specs.realEstateFurnitureType!,
            ),
            const SizedBox(height: 20),
          ],

          // ✅ (مش عمارات + مش أراضي)
          if (![
            RealEstateType.buildings,
            RealEstateType.lands,
          ].contains(type)) ...[
            SelectItemsWidget<int>(
              textFieldLabel: "${AppStrings.more}: ",
              controller: specs.realEstateRoomsController,
              onTextChanged: (v) {
                final value = int.tryParse((v ?? '').trim());
                if (value == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateRooms = value;
                });
              },
              title: AppStrings.roomCount,
              items: const [1, 2, 3, 4, 5, 6],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateRooms = v;
                  val.realEstateRoomsController?.text = "";
                });
              },
              selectedItems: [specs.realEstateRooms ?? 1],
            ),
            const SizedBox(height: 20),
          ],

          SelectItemsWidget<PaySystem>(
            controller: specs.realEstatePartsYears,
            textFieldLabel:
                specs.paySystem == PaySystem.cash
                    ? null
                    : "${AppStrings.yearCount}: ",
            title: AppStrings.paySystem,
            items: PaySystem.values,
            onChanged: (v) {
              if (v == null) return;
              controller.adRealEstateSpecs.update((val) {
                val!.paySystem = v;
              });
            },
            selectedItems: [specs.paySystem ?? PaySystem.cash],
          ),

          const SizedBox(height: 20),

          // ✅ المساحة (مش شقق)
          if (type != RealEstateType.apartments) ...[
            FromToField(
              title: AppStrings.space,
              from: specs.realEstateSpace!,
              to: specs.realEstateSpaceTo!,
            ),
            const SizedBox(height: 20),
          ],

          // ✅ أراضي فقط (عدد الشوارع)
          if (type == RealEstateType.lands) ...[
            SelectItemsWidget<int>(
              title: AppStrings.aroundStreets,
              items: const [0, 1, 2, 3, 4],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  if (val!.streetsAroundCount!.contains(v)) {
                    val.streetsAroundCount!.remove(v);
                  } else {
                    val.streetsAroundCount!.add(v);
                  }
                });
              },
              selectedItems: specs.streetsAroundCount!,
            ),
            const SizedBox(height: 20),
          ],

          // ✅ (مش عمارات + مش أراضي) حمامات
          if (![
            RealEstateType.buildings,
            RealEstateType.lands,
          ].contains(type)) ...[
            SelectItemsWidget<int>(
              textFieldLabel: "${AppStrings.more}: ",
              controller: specs.realEstateBathsController,
              onTextChanged: (v) {
                final value = int.tryParse((v ?? '').trim());
                if (value == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateBaths = value;
                });
              },
              title: AppStrings.bathroomCount,
              items: const [1, 2, 3, 4],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateBaths = v;
                  val.realEstateBathsController?.text = "";
                });
              },
              selectedItems: [specs.realEstateBaths ?? 1],
            ),
            const SizedBox(height: 20),
          ],

          // ✅ فلل فقط
          if (type == RealEstateType.villas) ...[
            SelectItemsWidget<int>(
              textFieldLabel: "${AppStrings.more}: ",
              controller: specs.realEstateGardensController,
              onTextChanged: (v) {
                final value = int.tryParse((v ?? '').trim());
                if (value == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateGardens = value;
                });
              },
              title: AppStrings.gardenCount,
              items: const [0, 1, 2, 3, 4],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateGardens = v;
                  val.realEstateGardensController?.text = "";
                });
              },
              selectedItems: [specs.realEstateGardens ?? 0],
            ),
            const SizedBox(height: 20),

            SelectItemsWidget<String>(
              title: AppStrings.bool,
              items: [AppStrings.yes, AppStrings.no],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateHasBool = v == AppStrings.yes;
                });
              },
              selectedItems: [
                (specs.realEstateHasBool ?? true)
                    ? AppStrings.yes
                    : AppStrings.no,
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ✅ شقق فقط
          if (type == RealEstateType.apartments) ...[
            SelectItemsWidget<String>(
              title: AppStrings.shareApartment,
              items: [AppStrings.yes, AppStrings.no],
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  val!.realEstateSharing = v == AppStrings.yes;
                });
              },
              selectedItems: [
                (specs.realEstateSharing ?? true)
                    ? AppStrings.yes
                    : AppStrings.no,
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ✅ عمارات فقط
          if (type == RealEstateType.buildings) ...[
            SelectItemsWidget<RealEstateBuilding>(
              title: AppStrings.building,
              items: RealEstateBuilding.values,
              onChanged: (v) {
                if (v == null) return;
                controller.adRealEstateSpecs.update((val) {
                  if (!val!.realEstateBuilding!.contains(v)) {
                    val.realEstateBuilding!.clear();
                    val.realEstateBuilding!.add(v);
                  }
                });
              },
              selectedItems: specs.realEstateBuilding!,
            ),
            const SizedBox(height: 20),
          ],

          // ✅ العملة (لما تجهزها من API)
          // ??????? ????????
          Obx(() {
            final options = InternalFeature.values.toList();
            return SelectItemsWidget<InternalFeature>(
              title: AppStrings.internalFeatures,
              items: options,
              onChanged: (v) {
                if (v == null) return;
                if (controller.internalFeatures.contains(v)) {
                  controller.internalFeatures.remove(v);
                } else {
                  controller.internalFeatures.add(v);
                }
                controller.internalFeatures.refresh();
              },
              selectedItems: controller.internalFeatures.toList(),
            );
          }),
          const SizedBox(height: 20),

          // قريبة من
          Obx(() {
            final options = NearbyPlace.values.toList();
            return SelectItemsWidget<NearbyPlace>(
              title: AppStrings.nearTo,
              items: options,
              onChanged: (v) {
                if (v == null) return;
                if (controller.nearbyPlaces.contains(v)) {
                  controller.nearbyPlaces.remove(v);
                } else {
                  controller.nearbyPlaces.add(v);
                }
                controller.nearbyPlaces.refresh();
              },
              selectedItems: controller.nearbyPlaces.toList(),
            );
          }),
        ],
      );
    });
  }
}
