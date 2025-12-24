import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/condition_status.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

class PostAdDetailsForm extends StatelessWidget {
  const PostAdDetailsForm({super.key, required this.controller, this.adType});

  final CreateAdsController controller;
  final AdType? adType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputField(
          keyboardType: TextInputType.text,
          labelText: AppStrings.adNameText,
          hintText: AppStrings.adNameHint,
        ),
        const SizedBox(height: 20),
        InputField(
          keyboardType: TextInputType.text,
          labelText: AppStrings.locationText,
          hintText: AppStrings.locationText,
        ),
        const SizedBox(height: 20),
        InputField(
          keyboardType: TextInputType.text,
          labelText: AppStrings.priceText,
          hintText: AppStrings.priceText,
        ),
        const SizedBox(height: 20),
        InputField(
          keyboardType: TextInputType.text,
          labelText: AppStrings.descriptionText,
          hintText: AppStrings.descriptionHint,
          maxLines: 5,
        ),
        const SizedBox(height: 15),
        ConditionStatus(controller: controller),
        const SizedBox(height: 15),
        InputField(
          keyboardType: TextInputType.text,
          labelText: AppStrings.partTypeText,
          hintText: AppStrings.partTypeHint,
          maxLines: 1,
        ),
        if (adType == AdType.real_estates) ...[
          const SizedBox(height: 20),
          InputField(
            keyboardType: TextInputType.text,
            labelText: AppStrings.realEstateType,
            hintText: AppStrings.realEstateType,
          ),
          const SizedBox(height: 20),
          InputField(
            keyboardType: TextInputType.number,
            labelText: AppStrings.space,
            hintText: AppStrings.space,
          ),
        ],
        if (adType == AdType.vehicles) ...[
          const SizedBox(height: 20),
          InputField(
            keyboardType: TextInputType.text,
            labelText: AppStrings.vehicleType,
            hintText: AppStrings.vehicleType,
          ),
          const SizedBox(height: 20),
          InputField(
            keyboardType: TextInputType.text,
            labelText: AppStrings.companyName,
            hintText: AppStrings.companyName,
          ),
        ],
      ],
    );
  }
}
