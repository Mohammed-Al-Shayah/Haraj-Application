import 'package:flutter/material.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import '../../../../core/theme/color.dart';
import '../../../../domain/entities/category_entity.dart';
import 'subcategories_item.dart';

class SubcategoriesCard extends StatelessWidget {
  final List<SubCategoryEntity> categorySelection;
  final bool isDrawer;
  final bool isPostAdFlow;
  final String? parentCategoryName;
  final String? parentCategoryNameEn;
  final AdType? parentAdType;
  final int? parentCategoryId;

  const SubcategoriesCard({
    super.key,
    required this.categorySelection,
    this.isDrawer = false,
    this.isPostAdFlow = false,
    this.parentCategoryName,
    this.parentCategoryNameEn,
    this.parentAdType,
    this.parentCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black75.withAlpha(8),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(right: 16, left: 16),
      child: Column(
        children: [
          for (int index = 0; index < categorySelection.length; index++)
            SubcategoriesItem(
              subcategories: categorySelection[index],
              isLast: index == categorySelection.length - 1,
              isPostAdFlow: isPostAdFlow,
              parentCategoryName: parentCategoryName,
              parentCategoryNameEn: parentCategoryNameEn,
              parentAdType: parentAdType,
              parentCategoryId: parentCategoryId,
            ),
        ],
      ),
    );

    if (isDrawer) {
      return content;
    } else {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }
  }
}
