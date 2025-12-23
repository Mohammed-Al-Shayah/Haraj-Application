import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../data/datasources/ads_remote_datasource.dart';
import '../../../../data/repositories/ad_repository_impl.dart';
import '../widgets/ads/ads_section.dart';
import '../widgets/ads/recent_items_section.dart';
import '../../controllers/ad_controller.dart';
import '../widgets/ads/recent_searches_header.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AdController(
        repository: AdRepositoryImpl(
          remoteDataSource: AdsRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
    );
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: MainBar(
        title: AppStrings.searchResult,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      body: Column(
        children: [
          Container(
            height: 94,
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: InputField(
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
                onEditingComplete: () => Get.toNamed(Routes.adsResultScreen),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.isEmpty) {
                return const SingleChildScrollView(
                  child: Column(
                    children: [RecentSearchesHeader(), RecentItemsSection()],
                  ),
                );
              } else if (controller.searchState.value == SearchState.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.searchState.value == SearchState.success) {
                return AdsSection(ads: controller.filteredAds);
              } else {
                return const Center(child: Text('Error occurred'));
              }
            }),
          ),
        ],
      ),
      drawer: SideMenu(),
    );
  }
}
