import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/widgets/authentication/social_media_button.dart';
import 'package:haraj_adan_app/data/api/auth_api.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/strings.dart';

class SocialMediaSection extends StatelessWidget {
  final bool isColumn;

  const SocialMediaSection({super.key, required this.isColumn});

  @override
  Widget build(BuildContext context) {
    final spacing =
        isColumn ? const SizedBox(height: 10) : const SizedBox(width: 16);

    return isColumn
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildSocialMediaButtons(spacing, true),
        )
        : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildSocialMediaButtons(spacing, false),
        );
  }

  List<Widget> _buildSocialMediaButtons(Widget spacing, bool showText) {
    return [
      SocialMediaButton(
        iconPath: AppAssets.googleIcon,
        text: showText ? AppStrings.continueWithGoogle : null,
        onPress: () {
          final AuthApi authApi = AuthApi(ApiClient(client: Dio()));
          authApi.googleAuthRedirect();
        },
      ),
      // spacing,
      // SocialMediaButton(
      //   iconPath: AppAssets.facebookIcon,
      //   text: showText ? AppStrings.continueWithFacebook : null,
      //   onPress: () {},
      // ),
      // spacing,
      // SocialMediaButton(
      //   iconPath: AppAssets.appleIcon,
      //   text: showText ? AppStrings.continueWithApple : null,
      //   onPress: () {},
      // ),
    ];
  }
}
