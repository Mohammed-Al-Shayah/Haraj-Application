import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../data/datasources/ads_remote_datasource.dart';
import '../../../../data/models/ad_model.dart';
import '../../../../data/repositories/ad_repository_impl.dart';
import '../../../filters/models/enums.dart';
import '../../../filters/views/screens/real_estate_filter.dart';
import '../../../filters/views/screens/vehicle_filter.dart';
import '../../../../core/widgets/side_menu.dart';
import '../widgets/ads/ad_item.dart';
import '../widgets/ads/ads_result_section.dart';
import '../../controllers/ad_controller.dart';
import '../widgets/ads/appearance_bottom_sheet.dart';
import '../widgets/ads/filter_sort_selector.dart';
import '../widgets/ads/sort_bottom_sheet.dart';

class AdsResultScreen extends StatelessWidget {
  const AdsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final categoryTitle =
        arguments?['categoryTitle'] as String? ?? AppStrings.searchResult;
    final AdType? passedAdType = arguments?['adType'] as AdType?;
    final int? categoryId = arguments?['categoryId'] as int?;
    final int? subCategoryId = arguments?['subCategoryId'] as int?;
    final int? subSubCategoryId = arguments?['subSubCategoryId'] as int?;
    final parentCategoryName =
        arguments?['parentCategoryName'] as String? ?? '';
    final parentCategoryNameEn =
        arguments?['parentCategoryNameEn'] as String? ?? '';
    final adType =
        passedAdType ??
        _resolveAdType(categoryTitle, parentCategoryName, parentCategoryNameEn);

    final controller = Get.put(
      AdController(
        repository: AdRepositoryImpl(
          remoteDataSource: AdsRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
    );
    controller.setCategoryFilters(
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      subSubCategoryId: subSubCategoryId,
    );

    /// Load all ads when coming from category (no query)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryTitle != AppStrings.searchResult) {
        controller.filterAds('');
      }
    });

    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.white,
      appBar: MainBar(
        // title: AppStrings.searchResult,
        title: categoryTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    controller: TextEditingController(),
                    validator: Validators.validatePublicText,
                    hintText: AppStrings.placeLocation,
                    prefixIconPath: AppAssets.searchIcon,
                    suffixIconColor: AppColors.white,
                    prefixIconColor: AppColors.white,
                    keyboardType: TextInputType.text,
                    hintStyleColor: AppColors.white,
                    fillColor: ColorScheme.fromSeed(
                      seedColor: AppColors.primary,
                    ).surface.withAlpha((0.3 * 255).toInt()),
                    enabledBorderColor: AppColors.transparent,
                    textColor: AppColors.white,
                    onChanged: (value) => controller.filterAds(value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilterSortSelector(
                        assetIcon: AppAssets.filterIcon,
                        onPress: () => _openFilterBottomSheet(adType),
                      ),
                      const SizedBox(width: 8),
                      FilterSortSelector(
                        text: AppStrings.sortBy,
                        onPress: () => _sortBottomSheet(controller),
                      ),
                      const SizedBox(width: 8),
                      FilterSortSelector(
                        text: AppStrings.appearance,
                        onPress: () => _appearanceBottomSheet(controller),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedAppearance.value != 'On Map') {
              return Column(
                children: [
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Obx(() {
                      return Text(
                        '${controller.filteredAds.length} ${AppStrings.resultAvailable}',
                        style: AppTypography.bold16,
                      );
                    }),
                  ),
                  const SizedBox(height: 10.0),
                ],
              );
            } else {
              return Container();
            }
          }),
          Obx(() {
            if (controller.selectedAppearance.value == 'On Map') {
              return Expanded(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(15.3694, 44.1910),
                    zoom: 5,
                  ),
                  markers: Set<Marker>.of(
                    controller.filteredAds.map((ad) {
                      return Marker(
                        markerId: MarkerId(ad.id.toString()),
                        position: LatLng(ad.latitude, ad.longitude),
                        onTap: () {
                          _showAdDetailsById(ad.id, context, controller);
                        },
                      );
                    }),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
          Obx(() {
            if (controller.selectedAppearance.value != 'On Map') {
              return Obx(() {
                if (controller.searchState.value == SearchState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.searchState.value ==
                    SearchState.success) {
                  return Expanded(
                    child: AdsResultSection(ads: controller.filteredAds),
                  );
                } else {
                  return const Center(child: Text('Error occurred'));
                }
              });
            } else {
              return Container();
            }
          }),
        ],
      ),
      drawer: SideMenu(),
    );
  }

  void _showAdDetailsById(
    int id,
    BuildContext context,
    AdController controller,
  ) {
    final ad = controller.filteredAds.firstWhere(
      (ad) => ad.id == id,
      orElse:
          () => AdModel(
            id: -1,
            imageUrl: '',
            title: 'Ad Not Found',
            location: '',
            price: 0.0,
            likesCount: 0,
            commentsCount: 0,
            createdAt: '',
            latitude: 0.0,
            longitude: 0.0,
            isLiked: false,
            likeId: null,
          ),
    );

    if (ad.id == -1) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return Container(
          height: 130,
          padding: const EdgeInsets.all(16.0),
          child: AdItem(
            imageUrl: ad.imageUrl,
            title: ad.title,
            location: ad.location,
            price: ad.price,
            onTap: () {},
          ),
        );
      },
    );
  }

  void _appearanceBottomSheet(AdController controller) {
    Get.bottomSheet(
      AppearanceBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }

  void _sortBottomSheet(AdController controller) {
    Get.bottomSheet(
      SortBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }

  void _openFilterBottomSheet(AdType type) {
    final bottomSheet =
        type == AdType.real_estates
            ? const RealEstateFilter()
            : const VehicleFilter();
    Get.bottomSheet(bottomSheet, isScrollControlled: true);
  }

  AdType _resolveAdType(
    String categoryTitle,
    String parentName,
    String parentNameEn,
  ) {
    final candidates =
        <String>[
          categoryTitle,
          parentName,
          parentNameEn,
        ].map(_normalizeName).where((e) => e.isNotEmpty).toList();

    final joined = candidates.join(' ');

    if (joined.contains('real estate') ||
        joined.contains('realestate') ||
        joined.contains('real_estate') ||
        joined.contains('عقار') ||
        joined.contains('عقارات')) {
      return AdType.real_estates;
    }

    if (joined.contains('vehicle') ||
        joined.contains('vehicles') ||
        joined.contains('car') ||
        joined.contains('cars') ||
        joined.contains('سيارة') ||
        joined.contains('سيارات') ||
        joined.contains('مركبات')) {
      return AdType.vehicles;
    }

    return AdType.vehicles;
  }

  String _normalizeName(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
