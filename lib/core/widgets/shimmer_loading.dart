import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class ShimmerController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController shimmerAnimation;
  RxDouble shimmerValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    shimmerAnimation =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            shimmerValue.value = shimmerAnimation.value;
          })
          ..repeat();
  }

  @override
  void onClose() {
    shimmerAnimation.dispose();
    super.onClose();
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerController = Get.put(ShimmerController());

    return Obx(() {
      final value = shimmerController.shimmerValue.value;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment(-1, 0),
            end: Alignment(1, 0),
            colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
            stops: [math.max(value - 0.3, 0), value, math.min(value + 0.3, 1)],
          ),
        ),
      );
    });
  }
}
