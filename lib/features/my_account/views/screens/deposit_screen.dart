import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/deposit_controller.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();

    return Scaffold(
      appBar: MainBar(title: AppStrings.deposit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.uploadInvoice, style: AppTypography.bold14),
            const SizedBox(height: 12),

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
                  padding: const EdgeInsets.all(12),
                  child: Obx(() {
                    final file = controller.uploadedFile.value;
                    return file == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.uploadIcon,
                              width: 80,
                              height: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.tapToUpload,
                              style: AppTypography.medium14,
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            file,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),
            InputField(
              keyboardType: TextInputType.number,
              labelText: AppStrings.amount,
              hintText: AppStrings.enterAmount,
              onChanged: controller.updatePrice,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Obx(
          () => PrimaryButton(
            onPressed:
                controller.isSubmitting.value
                    ? null
                    : () => controller.submit(),
            title: controller.isSubmitting.value ? '...' : AppStrings.submit,
          ),
        ),
      ),
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
