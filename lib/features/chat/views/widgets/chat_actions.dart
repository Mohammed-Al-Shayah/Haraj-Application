import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';

class ChatActions extends StatelessWidget {
  const ChatActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _iconButton(AppAssets.galleryIcon),
          const SizedBox(width: 4),
          _iconButton(AppAssets.folderIcon),
          const SizedBox(width: 8),
          Expanded(
            child: InputField(
              hintText: AppStrings.typeHere,
              keyboardType: TextInputType.text,
            ),
          ),
          const SizedBox(width: 8),
          _sendButton(context),
        ],
      ),
    );
  }

  Widget _iconButton(String assetPath) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SvgPicture.asset(assetPath, width: 24, height: 24),
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Theme.of(context).primaryColor,
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
