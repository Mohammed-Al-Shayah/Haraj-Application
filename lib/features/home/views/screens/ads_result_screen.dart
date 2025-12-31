import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/datasources/ads_remote_datasource.dart';
import '../../../../data/repositories/ad_repository_impl.dart';
import '../../../../core/routes/routes.dart';
import '../../../filters/models/enums.dart';
import '../../../filters/views/screens/real_estate_filter.dart';
import '../../../filters/views/screens/vehicle_filter.dart';
import '../../../../core/widgets/side_menu.dart';
import '../widgets/ads/ads_result_section.dart';
import '../../controllers/ad_controller.dart';
import '../widgets/ads/appearance_bottom_sheet.dart';
import '../widgets/ads/filter_sort_selector.dart';
import '../widgets/ads/sort_bottom_sheet.dart';

class AdsResultScreen extends StatefulWidget {
  const AdsResultScreen({super.key});

  @override
  State<AdsResultScreen> createState() => _AdsResultScreenState();
}

class _AdsResultScreenState extends State<AdsResultScreen> {
  late final Map<String, dynamic>? _arguments;
  late final String _categoryTitle;
  late final AdType _adType;
  late final int? _categoryId;
  late final int? _subCategoryId;
  late final int? _subSubCategoryId;
  late final AdController _controller;
  late final TextEditingController _searchController;
  late final ScrollController _listScrollController;
  String? _initialSearch;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  Cancelable? _tapEventsCancelable;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _listScrollController = ScrollController();
    _arguments = Get.arguments as Map<String, dynamic>?;
    _categoryTitle =
        _arguments?['categoryTitle'] as String? ?? AppStrings.searchResult;
    _initialSearch = _arguments?['searchQuery'] as String?;
    final AdType? passedAdType = _arguments?['adType'] as AdType?;
    _categoryId = _arguments?['categoryId'] as int?;
    _subCategoryId = _arguments?['subCategoryId'] as int?;
    _subSubCategoryId = _arguments?['subSubCategoryId'] as int?;
    final parentCategoryName =
        _arguments?['parentCategoryName'] as String? ?? '';
    final parentCategoryNameEn =
        _arguments?['parentCategoryNameEn'] as String? ?? '';
    _adType =
        passedAdType ??
        _resolveAdType(
          _categoryTitle,
          parentCategoryName,
          parentCategoryNameEn,
        );

    _controller =
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setCategoryFilters(
        categoryId: _categoryId,
        subCategoryId: _subCategoryId,
        subSubCategoryId: _subSubCategoryId,
      );

      if (_initialSearch != null && _initialSearch!.isNotEmpty) {
        _searchController.text = _initialSearch!;
        _controller.addRecentSearch(_initialSearch!);
        _controller.filterAds(_initialSearch!);
      } else if (_categoryTitle != AppStrings.searchResult) {
        _controller.filterAds('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listScrollController.dispose();
    _tapEventsCancelable?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      appBar: MainBar(
        // title: AppStrings.searchResult,
        title: _categoryTitle,
        menu: true,
        scaffoldKey: _scaffoldKey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
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
                    onChanged: (value) => _controller.filterAds(value),
                    onEditingComplete: () {
                      _controller.addRecentSearch(_searchController.text);
                      _controller.filterAds(_searchController.text);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilterSortSelector(
                        assetIcon: AppAssets.filterIcon,
                        onPress: () => _openFilterBottomSheet(_adType),
                      ),
                      const SizedBox(width: 8),
                      FilterSortSelector(
                        text: AppStrings.sortBy,
                        onPress: () => _sortBottomSheet(_controller),
                      ),
                      const SizedBox(width: 8),
                      FilterSortSelector(
                        text: AppStrings.appearance,
                        onPress: () => _appearanceBottomSheet(_controller),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (_controller.selectedAppearance.value != 'On Map') {
              return Column(
                children: [
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Obx(() {
                      return Text(
                        '${_controller.totalResults.value} ${AppStrings.resultAvailable}',
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
            if (_controller.selectedAppearance.value == 'On Map') {
              return Expanded(
                child: Obx(() {
                  final adsWithCoords =
                      _controller.filteredAds
                          .where((ad) => ad.latitude != 0 && ad.longitude != 0)
                          .toList();

                  if (_mapboxMap != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _refreshMapAnnotations(adsWithCoords);
                    });
                  }

                  final fallbackCenter = Point(
                    coordinates: Position(44.1910, 15.3694),
                  );

                  return Stack(
                    children: [
                      MapWidget(
                        key: const ValueKey('search_map'),
                        mapOptions: MapOptions(
                          pixelRatio: MediaQuery.of(context).devicePixelRatio,
                        ),
                        cameraOptions: CameraOptions(
                          center:
                              adsWithCoords.isNotEmpty
                                  ? Point(
                                    coordinates: Position(
                                      adsWithCoords.first.longitude,
                                      adsWithCoords.first.latitude,
                                    ),
                                  )
                                  : fallbackCenter,
                          zoom: adsWithCoords.isNotEmpty ? 10 : 5,
                        ),
                        onMapCreated: (controller) async {
                          _mapboxMap = controller;
                          await _mapboxMap?.gestures.updateSettings(
                            GesturesSettings(
                              scrollEnabled: true,
                              rotateEnabled: true,
                              pinchToZoomEnabled: true,
                              doubleTapToZoomInEnabled: true,
                              quickZoomEnabled: true,
                            ),
                          );
                          await _refreshMapAnnotations(adsWithCoords);
                        },
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              mini: true,
                              heroTag: 'search_map_zoom_in',
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              mini: true,
                              heroTag: 'search_map_zoom_out',
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              );
            } else {
              return Container();
            }
          }),
          Obx(() {
            if (_controller.selectedAppearance.value != 'On Map') {
              return Obx(() {
                final isInitialLoading =
                    _controller.searchState.value == SearchState.loading &&
                    _controller.filteredAds.isEmpty;
                final isError =
                    _controller.searchState.value == SearchState.error &&
                    _controller.filteredAds.isEmpty;

                if (isInitialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (isError) {
                  return _buildErrorView();
                }
                if (_controller.filteredAds.isEmpty) {
                  return const Center(child: Text('No results found'));
                }
                return Expanded(
                  child: AdsResultSection(
                    ads: _controller.filteredAds,
                    scrollController: _listScrollController,
                    isLoadingMore: _controller.isLoadingMore.value,
                    hasMore:
                        _controller.currentPage.value <
                        _controller.totalPages.value,
                    onLoadMore: _controller.loadNextPage,
                  ),
                );
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

  Widget _buildErrorView() {
    final message =
        _controller.errorMessage.value ??
        'Error occurred while loading results';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.bold16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed:
                  () => _controller.filterAds(_controller.searchQuery.value),
              title: 'Retry',
            ),
          ],
        ),
      ),
    );
  }

  void _openAdDetails(int adId) {
    final exists = _controller.filteredAds.any((ad) => ad.id == adId);
    if (!exists) return;

    Get.toNamed(Routes.adDetailsScreen, arguments: {'adId': adId});
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
    final args = Get.arguments as Map<String, dynamic>?;

    final String categoryTitle =
        args?['categoryTitle'] as String? ?? AppStrings.searchResult;

    final int categoryId = _categoryId ?? (args?['categoryId'] as int?) ?? 0;

    final bottomSheet =
        type == AdType.real_estates
            ? RealEstateFilter(
              categoryId: categoryId,
              categoryTitle: categoryTitle,
              onApply:
                  () => _controller.filterAds(_controller.searchQuery.value),
            )
            : VehicleFilter(
              categoryId: categoryId,
              categoryTitle: categoryTitle,
              onApply:
                  () => _controller.filterAds(_controller.searchQuery.value),
            );

    Get.bottomSheet(bottomSheet, isScrollControlled: true);
  }

  Future<void> _refreshMapAnnotations(List adsWithCoords) async {
    if (_mapboxMap == null) return;
    _annotationManager ??=
        await _mapboxMap!.annotations.createPointAnnotationManager();
    final manager = _annotationManager;
    if (manager == null) return;

    await manager.deleteAll();
    if (adsWithCoords.isEmpty) return;

    final options = <PointAnnotationOptions>[];
    for (final ad in adsWithCoords) {
      if (ad.latitude == 0 || ad.longitude == 0) continue;
      options.add(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              ad.longitude.toDouble(),
              ad.latitude.toDouble(),
            ),
          ),
          iconSize: 1.3,
          textField: ad.title,
          textOffset: const [0, 2],
          customData: {'adId': ad.id},
        ),
      );
    }

    await manager.createMulti(options);

    _tapEventsCancelable ??= manager.tapEvents(
      onTap: (annotation) {
        final adId = _readAnnotationAdId(annotation);
        if (adId != null && mounted) {
          _openAdDetails(adId);
        } else {
          final fallbackId = _findAdIdByLocation(annotation);
          if (fallbackId != null && mounted) {
            _openAdDetails(fallbackId);
          }
        }
      },
    );

    await _fitMapToAnnotations(options);
  }

  Future<void> _fitMapToAnnotations(
    List<PointAnnotationOptions> annotations,
  ) async {
    if (_mapboxMap == null || annotations.isEmpty) return;
    if (annotations.length == 1) {
      await _mapboxMap!.easeTo(
        CameraOptions(center: annotations.first.geometry, zoom: 12),
        MapAnimationOptions(duration: 500),
      );
      return;
    }

    double minLat = annotations.first.geometry.coordinates.lat.toDouble();
    double maxLat = annotations.first.geometry.coordinates.lat.toDouble();
    double minLng = annotations.first.geometry.coordinates.lng.toDouble();
    double maxLng = annotations.first.geometry.coordinates.lng.toDouble();

    for (final ann in annotations.skip(1)) {
      final lat = ann.geometry.coordinates.lat.toDouble();
      final lng = ann.geometry.coordinates.lng.toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: false,
    );

    try {
      final camera = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 80, left: 80, bottom: 89, right: 80),
        null,
        null,
        null,
        null,
      );
      await _mapboxMap!.easeTo(camera, MapAnimationOptions(duration: 500));
    } catch (_) {
      await _mapboxMap!.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position((minLng + maxLng) / 2, (minLat + maxLat) / 2),
          ),
          zoom: 10,
        ),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  int? _readAnnotationAdId(PointAnnotation annotation) {
    final raw = annotation.customData;
    if (raw is! Map) return null;
    final adId = raw?['adId'];
    if (adId == null) return null;
    return int.tryParse(adId.toString());
  }

  int? _findAdIdByLocation(PointAnnotation annotation) {
    final coords = annotation.geometry.coordinates;
    final lat = coords.lat.toDouble();
    final lng = coords.lng.toDouble();
    final match = _controller.filteredAds.firstWhereOrNull(
      (ad) => ad.latitude.toDouble() == lat && ad.longitude.toDouble() == lng,
    );
    return match?.id;
  }

  Future<double> _currentZoom() async {
    final state = await _mapboxMap?.getCameraState();
    return state?.zoom ?? 10;
  }

  Future<void> _zoomIn() async {
    if (_mapboxMap == null) return;
    final current = await _currentZoom();
    await _mapboxMap!.easeTo(
      CameraOptions(zoom: current + 1),
      MapAnimationOptions(duration: 300),
    );
  }

  Future<void> _zoomOut() async {
    if (_mapboxMap == null) return;
    final current = await _currentZoom();
    await _mapboxMap!.easeTo(
      CameraOptions(zoom: current - 1),
      MapAnimationOptions(duration: 300),
    );
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
        joined.contains('عقارات') ||
        joined.contains('بيت') ||
        joined.contains('بيوت') ||
        joined.contains('شقة') ||
        joined.contains('شقق') ||
        joined.contains('فيلا') ||
        joined.contains('فلل') ||
        joined.contains('فلة') ||
        joined.contains('ارض') ||
        joined.contains('اراضي') ||
        joined.contains('أراضي')) {
      return AdType.real_estates;
    }

    if (joined.contains('vehicle') ||
        joined.contains('vehicles') ||
        joined.contains('car') ||
        joined.contains('cars') ||
        joined.contains('سيارة') ||
        joined.contains('سيارات') ||
        joined.contains('مركبة') ||
        joined.contains('مركبات') ||
        joined.contains('عربية') ||
        joined.contains('عربيات')) {
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
