import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../../core/theme/color.dart';

class VerificationCodeInput extends StatelessWidget {
  final RxString otp;

  const VerificationCodeInput({super.key, required this.otp});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 6,
      defaultPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          color: ColorScheme.fromSeed(seedColor: AppColors.primary).surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          color: ColorScheme.fromSeed(seedColor: AppColors.primary).surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
      ),
      onChanged: (value) => otp.value = value,
      onCompleted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
