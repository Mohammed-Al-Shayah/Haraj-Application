import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/photos_form.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/steps_section.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/post_ad_details_form.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../widgets/form_buttons.dart';

class PostAdScreen extends StatelessWidget {
  PostAdScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final CreateAdsController controller = Get.put(CreateAdsController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String categoryTitle = args['categoryTitle'] ?? 'Category';

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: categoryTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Obx(() {
        return Column(
          children: [
            StepsSection(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: _buildStepForm(controller.currentStep.value),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormButtons(controller: controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepForm(int step) {
    switch (step) {
      case 1:
        return PostAdDetailsForm(controller: controller);
      case 2:
        return PhotosForm(controller: controller);
      default:
        return const SizedBox();
    }
  }
}
