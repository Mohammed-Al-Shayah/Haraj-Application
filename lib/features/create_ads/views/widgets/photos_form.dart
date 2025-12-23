import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/create_ads/controllers/create_ads_controller.dart';

class PhotosForm extends StatelessWidget {
  const PhotosForm({super.key, required this.controller});

  final CreateAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.uploadPhotosText, style: AppTypography.bold14),
        SizedBox(height: 12),
        GestureDetector(
          onTap: controller.pickImage,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.primary,
              radius: 15,
              dashWidth: 6,
              dashSpace: 4,
              strokeWidth: 1.5,
            ),
            child: Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.uploadIcon, width: 80, height: 80),
                  SizedBox(height: 20),
                  Text(
                    AppStrings.uploadPhotosSubText,
                    style: AppTypography.medium14,
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.imageFiles.isEmpty) return SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GridView.builder(
              itemCount: controller.imageFiles.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final file = controller.imageFiles[index].value;
                return buildFilePreview(file, index);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget buildFilePreview(File file, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              file,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => controller.imageFiles.removeAt(index),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(Icons.cancel, color: AppColors.primary, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.color = Colors.blue,
    this.strokeWidth = 1.5,
    this.radius = 15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);

    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;

        final segment = metric.extractPath(
          distance,
          next.clamp(0.0, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
