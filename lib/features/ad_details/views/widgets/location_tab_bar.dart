import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LocationTabBar extends StatefulWidget {
  const LocationTabBar({super.key});

  @override
  State<LocationTabBar> createState() => _LocationTabBarState();
}

class _LocationTabBarState extends State<LocationTabBar> {
  static const double initialLat = 12.7855;
  static const double initialLon = 45.0187;

  late MapboxMap mapboxMap;
  bool _mapReady = false;
  PointAnnotationManager? _annotationManager;
  double _currentLat = initialLat;
  double _currentLon = initialLon;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = (screenHeight * 0.3).clamp(220.0, 360.0).toDouble();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: mapHeight,
        child: Stack(
          children: [
            Listener(
              onPointerDown: (_) {
                _setParentScroll(enabled: false);
              },
              onPointerUp: (_) {
                _setParentScroll(enabled: true);
              },
              child: MapWidget(
                key: const ValueKey("mapWidget"),
                mapOptions: MapOptions(
                  pixelRatio: MediaQuery.of(context).devicePixelRatio,
                ),
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(initialLon, initialLat)),
                  zoom: 13.5,
                ),
                onTapListener: _onMapTap,
                onMapCreated: (controller) async {
                  mapboxMap = controller;
                  await mapboxMap.gestures.updateSettings(
                    GesturesSettings(
                      rotateEnabled: true,
                      pinchToZoomEnabled: true,
                      scrollEnabled: true,
                      doubleTapToZoomInEnabled: true,
                      quickZoomEnabled: true,
                    ),
                  );
                  _initPositionFromAd();
                  await _ensureManager();
                  await _refreshMarker();
                  setState(() => _mapReady = true);
                },
              ),
            ),

            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    mini: true,
                    heroTag: 'zoom_in',
                    onPressed: _mapReady ? _zoomIn : null,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    heroTag: 'zoom_out',
                    onPressed: _mapReady ? _zoomOut : null,
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 12,
              bottom: 12,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'center',
                onPressed: _mapReady ? _centerOnAden : null,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initPositionFromAd() {
    final ad = Get.find<AdDetailsController>().ad.value;
    _currentLat = ad?.latitude ?? initialLat;
    _currentLon = ad?.longitude ?? initialLon;
  }

  Future<void> _ensureManager() async {
    _annotationManager ??=
        await mapboxMap.annotations.createPointAnnotationManager();
  }

  Future<void> _refreshMarker() async {
    try {
      final ad = Get.find<AdDetailsController>().ad.value;
      final label = ad?.address ?? 'Location';
      await _ensureManager();
      final mgr = _annotationManager;
      if (mgr == null) return;
      await mgr.deleteAll();
      await mgr.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(_currentLon, _currentLat)),
          iconSize: 1.5,
          textField: label,
          textOffset: [0, 2],
        ),
      );
    } catch (e) {
      debugPrint('addMarker error: $e');
    }
  }

  Future<double> _currentZoom() async {
    final cameraState = await mapboxMap.getCameraState();
    return cameraState.zoom;
  }

  Future<void> _zoomIn() async {
    try {
      final currentZoom = await _currentZoom();
      final targetZoom = currentZoom + 1.0;
      await mapboxMap.easeTo(
        CameraOptions(zoom: targetZoom),
        MapAnimationOptions(duration: 300),
      );
    } catch (e) {
      debugPrint('zoomIn error: $e');
    }
  }

  Future<void> _zoomOut() async {
    try {
      final currentZoom = await _currentZoom();
      final targetZoom = currentZoom - 1.0;
      await mapboxMap.easeTo(
        CameraOptions(zoom: targetZoom),
        MapAnimationOptions(duration: 300),
      );
    } catch (e) {
      debugPrint('zoomOut error: $e');
    }
  }

  Future<void> _centerOnAden() async {
    try {
      await mapboxMap.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(_currentLon, _currentLat)),
          zoom: 13.5,
        ),
        MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      debugPrint('centerOnAden error: $e');
    }
  }

  Future<void> _onMapTap(MapContentGestureContext context) async {
    try {
      final geometry = context.point;
      final coords = geometry.coordinates;
      _currentLat = (coords.lat).toDouble();
      _currentLon = (coords.lng).toDouble();
      await _refreshMarker();
      await mapboxMap.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(_currentLon, _currentLat)),
          zoom: 14,
        ),
        MapAnimationOptions(duration: 300),
      );
    } catch (e) {
      debugPrint('onMapTap error: $e');
    }
  }

  void _setParentScroll({required bool enabled}) {
    ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      if (!enabled) {
        scrollable.position.isScrollingNotifier.value = true;
      } else {
        scrollable.position.isScrollingNotifier.value = false;
      }
    }
  }
}
