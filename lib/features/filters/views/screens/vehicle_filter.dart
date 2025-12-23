import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/filters/controllers/filter_controller.dart';
import 'package:haraj_adan_app/features/filters/models/ad_vehicle_model.dart';
import 'package:haraj_adan_app/features/filters/models/dropdown_button_model.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/features/filters/views/screens/filter_template.dart';
import 'package:haraj_adan_app/core/widgets/dropdown_button.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/from_to_field.dart';
import 'package:haraj_adan_app/features/filters/views/widgets/select_items.dart';

class VehicleFilter extends StatelessWidget {
  const VehicleFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: GetX(
            tag: "vehicles",
            init: FilterController(AdType.vehicles),
            builder: (controller) {
              return FilterTemplate(
                onResetFilter: () {
                  controller.adVehicle.value =
                      AdVehicleFilterModel.initialize();
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonWidget(
                            selectedItem: AdType.vehicles,
                            items: [
                              DropdownButtonModel(
                                  dropValue: AdType.vehicles,
                                  dropText: AdType.vehicles.name.tr())
                            ],
                            title: AppStrings.category),
                        const Space(),
                        SelectItemsWidget<VehicleType>(
                            title: AppStrings.theType,
                            items: VehicleType.values,
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                if (!val!.vehicleType!.contains(v)) {
                                  val.vehicleType!.clear();
                                  val.vehicleType!.add(v!);
                                }
                              });
                            },
                            selectedItems:
                                controller.adVehicle.value.vehicleType!),
                        const Space(),
                        SelectItemsWidget<AdCategory>(
                            title: AppStrings.adType,
                            items: AdCategory.values,
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                if (!val!.adCategory!.contains(v)) {
                                  val.adCategory!.clear();
                                  val.adCategory!.add(v!);
                                }
                              });
                            },
                            selectedItems:
                                controller.adVehicle.value.adCategory!),
                        const Space(),
                        DropdownButtonWidget(
                            onChanged: (v) {},
                            hint: AppStrings.companyName,
                            selectedItem: controller.adVehicle.value.companyId,
                            items: const [],
                            title: AppStrings.vehicleCompany),
                        const Space(),
                        DropdownButtonWidget(
                            onChanged: (v) {},
                            hint: AppStrings.vehicleType,
                            selectedItem: controller.adVehicle.value.carTypeId,
                            items: const [],
                            title: AppStrings.vehicleType),
                        const Space(),
                        FromToField(
                            title: AppStrings.wolked,
                            from:
                                controller.adVehicle.value.vehicleWalkedByKilo!,
                            to: controller
                                .adVehicle.value.vehicleWalkedByKiloTo!),
                        const Space(),
                        FromToField(
                            title: AppStrings.yearMade,
                            from: controller.adVehicle.value.vehicleMadeYear!,
                            to: controller.adVehicle.value.vehicleMadeYearTo!),
                        const Space(),
                        SelectItemsWidget<String>(
                            title: AppStrings.machine,
                            items: const ["1.3", "1.6", "1.9"],
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                val!.vehicleMachine = v;
                              });
                            },
                            selectedItems: [
                              controller.adVehicle.value.vehicleMachine!
                            ]),
                        const Space(),
                        SelectItemsWidget<JerType>(
                            title: AppStrings.jerType,
                            items: JerType.values,
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                val!.vehicleJerType = v;
                              });
                            },
                            selectedItems: [
                              controller.adVehicle.value.vehicleJerType!
                            ]),
                        const Space(),
                        SelectItemsWidget<FuelType>(
                            title: AppStrings.fuelType,
                            items: FuelType.values,
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                if (val!.vehicleFuelType!.contains(v!)) {
                                  val.vehicleFuelType!.remove(v);
                                } else {
                                  val.vehicleFuelType!.add(v);
                                }
                              });
                            },
                            selectedItems:
                                controller.adVehicle.value.vehicleFuelType!),
                        const Space(),
                        SelectItemsWidget<PaySystem>(
                            controller:
                                controller.adVehicle.value.vehicleMadeYear!,
                            textFieldLabel:
                                controller.adVehicle.value.paySystem ==
                                        PaySystem.cash
                                    ? null
                                    : "${AppStrings.yearCount}: ",
                            title: AppStrings.paySystem,
                            items: PaySystem.values,
                            onChanged: (v) {
                              controller.adVehicle.update((val) {
                                val!.paySystem = v;
                              });
                            },
                            selectedItems: [
                              controller.adVehicle.value.paySystem!
                            ]),
                        const Space(),
                        SelectItemsWidget(
                            title: AppStrings.currency,
                            items: const [],
                            onChanged: (v) {
                              // controller.adVehicle.update((val){
                              //   if(val!.currencyId != v){
                              //     val.currencyId = v;
                              //   }
                              // });
                            },
                            selectedItems: [
                              controller.adVehicle.value.currencyId
                            ]),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}

class Space extends StatelessWidget {
  const Space({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
    );
  }
}
