import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart'
    as ui_category;
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import '../controllers/home_controller.dart';

extension HomeCategoriesExtension on HomeController {
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final result = await homeRepository.getHomeCategories();
      categories.assignAll(
        result.map((c) {
          final fallbackNameEn = c.nameEn.isNotEmpty ? c.nameEn : c.name;
          return ui_category.CategoryModel(
            id: c.id,
            parentId: c.parentId,
            name: c.name,
            nameEn: fallbackNameEn,
            image: c.image,
            adsCount: c.adsCount,
            children: c.children,
          );
        }).toList(),
      );
    } catch (e) {
      AppSnack.error('Error', e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }
}
