import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';

class TabBarSettings extends StatelessWidget {
  const TabBarSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      dividerHeight: 0,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.primary,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColors.white,
      unselectedLabelColor: AppColors.black75,
      tabs: [
        Container(
          width: 100,
          height: 32,
          alignment: Alignment.center,
          child: Tab(text: AppStrings.detailsText),
        ),
        Container(
          width: 100,
          height: 32,
          alignment: Alignment.center,
          child: Tab(text: AppStrings.descriptionText),
        ),
        Container(
          width: 100,
          height: 32,
          alignment: Alignment.center,
          child: Tab(text: AppStrings.locationText),
        ),
      ],
    );
  }
}
