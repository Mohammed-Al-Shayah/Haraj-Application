import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import '../../../../core/widgets/category/category_card.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../controllers/select_ad_controller.dart';
import '../../../home/repo/categories_repo.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class SelectAdScreen extends StatelessWidget {
  SelectAdScreen({super.key});

  final SelectAdController controller =
      Get.put(SelectAdController(CategoriesRepository(ApiClient(client: Dio()))));

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.postAdTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CategoryCard(categories: controller.categories, isPostAdFlow: true),
          ],
        ),
      ),
    );
  }
}
