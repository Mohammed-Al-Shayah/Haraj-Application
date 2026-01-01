import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_detail_controller.dart';

class ChatActions extends StatefulWidget {
  const ChatActions({super.key});

  @override
  State<ChatActions> createState() => _ChatActionsState();
}

class _ChatActionsState extends State<ChatActions> {
  final TextEditingController _controller = TextEditingController();
  late final ChatDetailController chatController;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatDetailController>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              controller: _controller,
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
        onTap: () {
          chatController.sendMessage(_controller.text);
          _controller.clear();
        },
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
