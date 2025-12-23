import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/comment_controller.dart';

import 'package:haraj_adan_app/features/ad_details/views/widgets/question_card.dart';

class QuestionsSection extends StatelessWidget {
  const QuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.questionSectionTitle, style: AppTypography.bold14),
        const SizedBox(height: 9),
        Text(AppStrings.questionSectionSubTitle, style: AppTypography.normal12),
        const SizedBox(height: 16),

        Obx(() {
          // أول تحميل
          if (controller.isLoading.value && controller.comments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // خطأ بدون بيانات
          if (controller.error.value.isNotEmpty &&
              controller.comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                controller.error.value,
                style: AppTypography.normal14.copyWith(color: Colors.red),
              ),
            );
          }

          // فاضي
          if (controller.comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No comments', style: AppTypography.normal14),
            );
          }

          // قائمة التعليقات
          return QuestionCard(comments: controller.comments);
        }),

        // Load more
        Obx(() {
          if (controller.comments.isEmpty) return const SizedBox.shrink();
          if (!controller.hasMore.value) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: controller.isLoading.value ? null : controller.loadMore,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load more'),
            ),
          );
        }),

        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: InputField(
                hintText: AppStrings.questionHintText,
                keyboardType: TextInputType.text,
                controller: controller.commentTextController,
              ),
            ),
            const SizedBox(width: 10),

            Obx(() {
              final disabled = controller.isPosting.value;

              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: disabled
                      // ignore: deprecated_member_use
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: disabled
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 24),
                  onPressed: disabled ? null : controller.submitComment,
                ),
              );
            }),
          ],
        ),

        // error under input (لو صار)
        Obx(() {
          if (controller.error.value.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.error.value,
              style: AppTypography.normal12.copyWith(color: Colors.red),
            ),
          );
        }),
      ],
    );
  }
}
