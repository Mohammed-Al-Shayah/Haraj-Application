import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/post_ad_form_controller.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/photos_form.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/steps_section.dart';
import 'package:haraj_adan_app/features/create_ads/views/widgets/post_ad_details_form.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';
import 'package:haraj_adan_app/data/datasources/post_ad_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/post_ad_repository_impl.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:dio/dio.dart';
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
  late final PostAdFormController postForm;

  late final Map _args;
  AdType? _adType;
  int? _categoryId;
  String _categoryTitle = 'Category';
  RealEstateType? _initialRealEstateType;

  @override
  void initState() {
    super.initState();

    _args = (Get.arguments ?? {}) as Map;

    _adType = _args['adType'] as AdType?;
    _categoryId = _args['categoryId'] as int?;
    _categoryTitle = (_args['categoryTitle'] ?? 'Category').toString();
    _initialRealEstateType = _args['realEstateType'] as RealEstateType?;

    if (_categoryId == null || _categoryId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Category is required to post an ad');
        Get.back();
      });
      return;
    }

    controller =
        Get.isRegistered<CreateAdsController>()
            ? Get.find<CreateAdsController>()
            : Get.put(CreateAdsController());
    final apiClient = ApiClient(client: Dio());
    final formTag = 'post_ad_form_${_categoryId!}';
    postForm = Get.put(
      PostAdFormController(
        repo: PostAdRepositoryImpl(PostAdRemoteDataSourceImpl(apiClient)),
        categoryId: _categoryId!,
      ),
      tag: formTag,
    );

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
    if (_categoryId == null || _categoryId == 0) {
      return const Scaffold(body: Center(child: Text('Category is required')));
    }

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
              child: Obx(
                () => FormButtons(
                  controller: controller,
                  onSubmit: _submitAd,
                  isSubmitting: postForm.isSubmitting.value,
                ),
              ),
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
          postForm: postForm,
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

  Future<void> _submitAd() async {
    postForm.title.value = controller.titleCtrl.text.trim();
    postForm.titleEn.value = controller.titleCtrl.text.trim();
    postForm.price.value = controller.priceCtrl.text.trim();
    postForm.descr.value = controller.descriptionCtrl.text.trim();
    await postForm.ensureLocationIfEmpty();
    postForm.address.value = controller.locationCtrl.text.trim();
    // lat/lng not captured in UI; send zeros to satisfy API requirements
    postForm.lat.value =
        postForm.lat.value.isNotEmpty ? postForm.lat.value : '0';
    postForm.lng.value =
        postForm.lng.value.isNotEmpty ? postForm.lng.value : '0';
    // currency: try to read from realEstateSpecs if set
    final cid = controller.adRealEstateSpecs.value.currencyId;
    if (cid != null) {
      postForm.currencyId.value = cid;
    }
    postForm.images.assignAll(
      controller.imageFiles.map((rx) => rx.value).toList(),
    );
    await postForm.submit();
  }

  @override
  void dispose() {
    final formTag = 'post_ad_form_${_categoryId ?? ''}';
    if (Get.isRegistered<PostAdFormController>(tag: formTag)) {
      Get.delete<PostAdFormController>(tag: formTag);
    }
    super.dispose();
  }
}
