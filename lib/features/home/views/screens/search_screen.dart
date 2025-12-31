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
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../data/datasources/ads_remote_datasource.dart';
import '../../../../data/repositories/ad_repository_impl.dart';
import '../widgets/ads/ads_section.dart';
import '../widgets/ads/recent_items_section.dart';
import '../../controllers/ad_controller.dart';
import '../widgets/ads/recent_searches_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final AdController controller;
  late final TextEditingController _searchController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    controller =
        Get.isRegistered<AdController>()
            ? Get.find<AdController>()
            : Get.put(
              AdController(
                repository: AdRepositoryImpl(
                  remoteDataSource: AdsRemoteDataSourceImpl(
                    ApiClient(client: Dio()),
                  ),
                ),
              ),
            );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _searchController,
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
                onEditingComplete: () {
                  controller.addRecentSearch(_searchController.text);
                  controller.filterAds(_searchController.text);
                  Get.toNamed(
                    Routes.adsResultScreen,
                    arguments: {'searchQuery': _searchController.text},
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                final isInputEmpty = value.text.trim().isEmpty;

                return Obx(() {
                  if (isInputEmpty) {
                    if (controller.recentSearches.isNotEmpty) {
                      final hasRecents = controller.recentSearches.isNotEmpty;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            RecentSearchesHeader(
                              onClear: controller.clearRecentSearches,
                              hasRecents: hasRecents,
                            ),
                            RecentItemsSection(
                              controller: controller,
                              searchController: _searchController,
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          AppStrings.noRecentSearches,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (controller.searchState.value ==
                      SearchState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.searchState.value ==
                          SearchState.success &&
                      controller.filteredAds.isEmpty) {
                    return const Center(child: Text('No results found'));
                  } else if (controller.searchState.value ==
                      SearchState.success) {
                    return AdsSection(ads: controller.filteredAds);
                  } else {
                    return _buildErrorView();
                  }
                });
              },
            ),
          ),
        ],
      ),
      drawer: SideMenu(),
    );
  }

  Widget _buildErrorView() {
    final message =
        controller.errorMessage.value ?? 'Error occurred while searching';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed:
                  () => controller.filterAds(controller.searchQuery.value),
              title: 'Retry',
            ),
          ],
        ),
      ),
    );
  }
}
