import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import '../../../features/home/models/category.model.dart';
import 'category_item.dart';

class CategoryCard extends StatelessWidget {
  final RxList<CategoryModel> categories;
  final bool isDrawer;
  final bool isPostAdFlow;

  const CategoryCard({
    super.key,
    required this.categories,
    this.isDrawer = false,
    this.isPostAdFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget content = Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black75.withAlpha((0.03 * 255).round()),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.only(right: 20, left: 20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            for (int index = 0; index < categories.length; index++)
              CategoryItem(
                category: categories[index],
                isLast: index == categories.length - 1,
                isPostAdFlow: isPostAdFlow,
              ),
          ],
        ),
      );

      return isDrawer
          ? content
          : Padding(padding: const EdgeInsets.all(20.0), child: content);
    });
  }
}
