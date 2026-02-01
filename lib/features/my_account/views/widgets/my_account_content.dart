import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/features/my_account/controllers/my_account_controller.dart';

class MyAccountContent extends StatelessWidget {
  const MyAccountContent({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAccountController controller = Get.find<MyAccountController>();
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildWalletSection(controller, isRtl),
          const SizedBox(height: 10),
          _buildAdvertisementManagementSection(controller),
          const SizedBox(height: 16),
          _buildMessagesAndInfoSection(context, controller, isRtl),
          const SizedBox(height: 16),
          _buildFavouritesSection(controller, isRtl),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => controller.onLogout(),
            title: AppStrings.logOutText,
            backgroundColor: AppColors.white,
            textColor: AppColors.red,
            leadingIcon: AppAssets.logoutIcon,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(MyAccountController controller, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.walletAndDepositText, style: AppTypography.semiBold14),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray300, width: 0.1),
          ),
          child: Column(
            children: [
              _customTile(
                title: AppStrings.wallet,
                trailing: const Text('(0)', style: AppTypography.normal12),
                onTap: () => Get.toNamed(Routes.walletScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              _customTile(
                title: AppStrings.deposit,
                trailing: SvgPicture.asset(
                  isRtl ? AppAssets.arrowLeftIcon : AppAssets.arrowRightIcon,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () => Get.toNamed(Routes.depositScreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertisementManagementSection(MyAccountController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.advertisementManagementText,
          style: AppTypography.semiBold14,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray300, width: 0.1),
          ),
          child: Column(
            children: [
              _customTile(
                title: AppStrings.onAirText,
                trailing: Obx(
                  () =>
                      controller.isStatsLoading.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            '(${controller.publishedCount.value})',
                            style: AppTypography.normal12,
                          ),
                ),
                onTap: () => Get.toNamed(Routes.onAirScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              _customTile(
                title: AppStrings.notPublishedText,
                trailing: Obx(
                  () =>
                      controller.isStatsLoading.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            '(${controller.unpublishedCount.value})',
                            style: AppTypography.normal12,
                          ),
                ),
                onTap: () => Get.toNamed(Routes.notPublishedScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              _customTile(
                title: AppStrings.featuredAdsText,
                trailing: Obx(
                  () =>
                      controller.isStatsLoading.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            '(${controller.featuredCount.value})',
                            style: AppTypography.normal12,
                          ),
                ),
                onTap: () => Get.toNamed(Routes.featuredAdsScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              _customTile(
                title: AppStrings.rejectedAdsText,
                trailing: Obx(
                  () =>
                      controller.isStatsLoading.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            '(${controller.rejectedCount.value})',
                            style: AppTypography.normal12,
                          ),
                ),
                onTap: () => Get.toNamed(Routes.rejectedScreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesAndInfoSection(
    BuildContext context,
    MyAccountController controller,
    bool isRtl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.messagesAndInformationsText,
          style: AppTypography.semiBold14,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray300, width: 0.1),
          ),
          child: Column(
            children: [
              _customTile(
                title: AppStrings.messagesText,
                trailing: SvgPicture.asset(
                  isRtl ? AppAssets.arrowLeftIcon : AppAssets.arrowRightIcon,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () => Get.toNamed(Routes.chatsScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              _customTile(
                title: AppStrings.permissionsText,
                trailing: SvgPicture.asset(
                  isRtl ? AppAssets.arrowLeftIcon : AppAssets.arrowRightIcon,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () => Get.toNamed(Routes.permissionsScreen),
              ),
              const Divider(height: 1, indent: 15, endIndent: 20),
              Obx(() {
                final langCode = controller.currentLanguage.value;
                final langLabel =
                    langCode == 'ar' ? AppStrings.arabic : AppStrings.english;
                return _customTile(
                  title: AppStrings.chooseLanguage,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(langLabel, style: AppTypography.normal12),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        isRtl ? AppAssets.arrowLeftIcon : AppAssets.arrowRightIcon,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showLanguageSheet(context, controller),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavouritesSection(MyAccountController controller, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.favouritesText, style: AppTypography.semiBold14),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray300, width: 0.1),
          ),
          child: _customTile(
            title: AppStrings.favouriteAdsText,
            trailing: SvgPicture.asset(
              isRtl ? AppAssets.arrowLeftIcon : AppAssets.arrowRightIcon,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => Get.toNamed(Routes.favouriteAdsScreen),
          ),
        ),
      ],
    );
  }

  Widget _customTile({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title, style: AppTypography.medium14), trailing],
        ),
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    MyAccountController controller,
  ) {
    final current = controller.currentLanguage.value;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.chooseLanguage, style: AppTypography.bold14),
                const SizedBox(height: 12),
                _languageOption(
                  title: AppStrings.arabic,
                  isSelected: current == 'ar',
                  onSelect: () => _applyLanguage(sheetContext, controller, 'ar'),
                ),
                _languageOption(
                  title: AppStrings.english,
                  isSelected: current == 'en',
                  onSelect: () => _applyLanguage(sheetContext, controller, 'en'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required String title,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.medium14),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onSelect,
    );
  }

  void _applyLanguage(
    BuildContext context,
    MyAccountController controller,
    String code,
  ) {
    controller.updateLanguage(code);
    Navigator.of(context).pop();
  }
}
