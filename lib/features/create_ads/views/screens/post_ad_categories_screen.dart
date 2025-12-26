import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/widgets/category/category_card.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

class PostAdCategoriesScreen extends StatelessWidget {
  const PostAdCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = (Get.arguments ?? {}) as Map;

    final CategoryModel? category = args['category'] as CategoryModel?;
    final String title = (args['title'] ?? category?.name ?? '').toString();

    if (category == null) {
      return const Scaffold(body: Center(child: Text('Category not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: CategoryCard(
          categories: category.children.obs,
          isPostAdFlow: true,
        ),
      ),
    );
  }
}
