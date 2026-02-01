import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/authentication/email_verification/controllers/verification_controller.dart';
import '../../routes/routes.dart';
import '../../theme/typography.dart';

class AuthSection extends StatefulWidget {
  final bool isRegister;
  final bool resendCode;

  const AuthSection({
    super.key,
    required this.isRegister,
    this.resendCode = false,
  });

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  static const _cooldownSeconds = 60;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    if (widget.resendCode) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant AuthSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.resendCode && widget.resendCode) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isCounting = _secondsLeft > 0;
    return Column(
      children: [
        if (widget.resendCode)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.didNotReceiveCode, style: AppTypography.medium14),
              const SizedBox(width: 6),
              if (isCounting)
                Text(
                  _formatTime(_secondsLeft),
                  style: AppTypography.medium14.copyWith(
                    color: AppColors.primary,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Get.find<VerificationController>().resendOtp();
                    _startTimer();
                  },
                  child: Text(
                    AppStrings.resend,
                    style: AppTypography.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        if (!widget.resendCode) ...[
          if (widget.isRegister)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.alreadyHaveAccount,
                  style: AppTypography.medium14,
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.loginScreen),
                  child: Text(
                    AppStrings.logIn,
                    style: AppTypography.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          if (!widget.isRegister)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.doNotHaveAccount),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.registerScreen),
                  child: Text(
                    AppStrings.register,
                    style: AppTypography.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
