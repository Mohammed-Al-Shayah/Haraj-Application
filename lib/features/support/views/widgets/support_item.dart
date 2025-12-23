import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/routes/routes.dart';
import '../../models/support_model.dart';

class SupportItem extends StatelessWidget {
  final Support support;

  const SupportItem({super.key, required this.support});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.supportDetailScreen),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                      support.image.isNotEmpty
                          ? Image.network(
                            support.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            width: 50,
                            height: 50,
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                support.name.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                ),
                if (support.isOnline)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.green00CD52,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(support.name, style: AppTypography.semiBold14),
                  const SizedBox(height: 2),
                  Text(
                    support.message,
                    style: AppTypography.normal14.copyWith(
                      color: AppColors.gray500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  support.time,
                  style: AppTypography.normal12.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 5),
                if (support.isOnline)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        textAlign: TextAlign.center,
                        style: AppTypography.semiBold10.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
