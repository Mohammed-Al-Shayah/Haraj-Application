import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/filters/views/screens/dynamic_category_filter.dart';
import 'package:haraj_adan_app/features/home/controllers/ad_controller.dart';

class RealEstateFilter extends StatelessWidget {
  const RealEstateFilter({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    this.onApply,
  });

  final int categoryId;
  final String categoryTitle;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();
    return DynamicCategoryFilter(
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      adController: adController,
      onApply: onApply,
    );
  }
}
