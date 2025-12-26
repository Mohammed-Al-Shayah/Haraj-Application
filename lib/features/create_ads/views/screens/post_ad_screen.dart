import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/photos_form.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/steps_section.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/post_ad_details_form.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../widgets/form_buttons.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late final CreateAdsController controller;

  late final Map _args;
  AdType? _adType;
  int? _categoryId;
  String _categoryTitle = 'Category';
  RealEstateType? _initialRealEstateType;

  @override
  void initState() {
    super.initState();

    controller =
        Get.isRegistered<CreateAdsController>()
            ? Get.find<CreateAdsController>()
            : Get.put(CreateAdsController());

    _args = (Get.arguments ?? {}) as Map;

    _adType = _args['adType'] as AdType?;
    _categoryId = _args['categoryId'] as int?;
    _categoryTitle = (_args['categoryTitle'] ?? 'Category').toString();
    _initialRealEstateType = _args['realEstateType'] as RealEstateType?;

    debugPrint('=== PostAdScreen args ===');
    debugPrint('adType=$_adType');
    debugPrint('categoryId=$_categoryId');
    debugPrint('categoryTitle=$_categoryTitle');
    debugPrint('realEstateType=$_initialRealEstateType');

    controller.initFromArgs(
      adTypeArg: _adType,
      initialRealEstateType: _initialRealEstateType,
      categoryIdArg: _categoryId,
      categoryTitleArg: _categoryTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: _categoryTitle,
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
        return PostAdDetailsForm(
          controller: controller,
          adType: _adType,
          categoryId: _categoryId,
          categoryTitle: _categoryTitle,
        );
      case 2:
        return PhotosForm(controller: controller);
      default:
        return const SizedBox();
    }
  }
}
