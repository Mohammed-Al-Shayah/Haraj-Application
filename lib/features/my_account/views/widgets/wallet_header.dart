// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/features/my_account/controllers/wallet_controller.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            color: AppColors.primary,
          ),
          Positioned(
            top: 30,
            left: isRtl ? null : 20,
            right: isRtl ? 20 : null,
            child: Container(
              height: 160,
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white.withAlpha((0.08 * 255).toInt()),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background artwork
                    Positioned.fill(
                      child:
                          isRtl
                              ? SvgPicture.asset(
                                AppAssets.walletImage,
                                fit: BoxFit.cover,
                              )
                              : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(3.1416),
                                child: SvgPicture.asset(
                                  AppAssets.walletImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),
                    // Subtle overlay to keep text readable on top of the SVG
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    AppAssets.coinIcon,
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.balance,
                                    style: AppTypography.semiBold16.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                AppAssets.visaIcon,
                                width: 44,
                                height: 28,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Obx(() {
                            final summary = controller.summary.value;
                            final balanceText = summary?.balance ?? '0';

                            return Text(
                              balanceText,
                              style: AppTypography.semiBold20.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.availableBalance,
                            style: AppTypography.normal14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
