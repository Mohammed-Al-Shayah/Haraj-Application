import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../../../../core/widgets/primary_button.dart';

class FilterTemplate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onApplyFilter;
  final VoidCallback? onResetFilter;

  const FilterTemplate(
      {super.key, required this.child, this.onApplyFilter, this.onResetFilter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15), topLeft: Radius.circular(15))),
          height: 40,
          alignment: Alignment.center,
          child: Container(
            height: 5,
            width: 50,
            decoration: const BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: AppColors.gray50,
            resizeToAvoidBottomInset: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppStrings.filter,
                    style:
                        AppTypography.bold24.copyWith(color: AppColors.black75),
                  ),
                ),
                Expanded(child: child),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Expanded(
                          child: PrimaryButton(
                              onPressed: onApplyFilter ?? () {},
                              title: AppStrings.applyFilter)),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                          child: PrimaryButton(
                              onPressed: onResetFilter ?? () {},
                              title: AppStrings.filterReset,
                              backgroundColor: AppColors.gray100)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
