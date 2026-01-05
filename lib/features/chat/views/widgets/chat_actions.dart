import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/chat/controllers/chat_detail_controller.dart';
import 'package:image_picker/image_picker.dart';

class ChatActions extends StatefulWidget {
  const ChatActions({super.key});

  @override
  State<ChatActions> createState() => _ChatActionsState();
}

class _ChatActionsState extends State<ChatActions> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
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
          _iconButton(AppAssets.galleryIcon, _pickImage),
          const SizedBox(width: 4),
          _iconButton(AppAssets.folderIcon, _pickFile),
          const SizedBox(width: 8),
          Expanded(
            child: InputField(
              controller: _controller,
              hintText: AppStrings.typeHere,
              keyboardType: TextInputType.text,
              onEditingComplete: _sendText,
            ),
          ),
          const SizedBox(width: 8),
          _sendButton(context),
        ],
      ),
    );
  }

  Widget _iconButton(String assetPath, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
        onTap: _sendText,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Future<void> _sendText() async {
    await chatController.sendMessage(_controller.text);
    _controller.clear();
  }

  Future<void> _pickImage() async {
    if (chatController.isSending.value) return;
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (result == null) return;
    final confirmed = await _confirmSendMedia(
      filePath: result.path,
      type: 'image',
      preview: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(result.path),
          fit: BoxFit.cover,
          height: 200,
          width: 280,
        ),
      ),
      name: result.name,
    );
    if (!confirmed) return;
    await chatController.sendMedia(filePath: result.path, type: 'image');
  }

  Future<void> _pickFile() async {
    if (chatController.isSending.value) return;
    final res = await FilePicker.platform.pickFiles(
      withData: false,
      allowMultiple: false,
      type: FileType.any,
    );
    final file = res?.files.single;
    if (file?.path == null) return;
    final ext = file!.extension?.toLowerCase() ?? '';
    final isImage = ['png', 'jpg', 'jpeg', 'heic', 'webp'].contains(ext);
    final preview =
        isImage
            ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(file.path!),
                fit: BoxFit.cover,
                height: 200,
                width: 280,
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insert_drive_file, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(file.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            );

    final confirmed = await _confirmSendMedia(
      filePath: file.path!,
      type: isImage ? 'image' : 'file',
      preview: preview,
      name: file.name,
    );
    if (!confirmed) return;
    await chatController.sendMedia(
      filePath: file.path!,
      type: isImage ? 'image' : 'file',
    );
  }

  Future<bool> _confirmSendMedia({
    required String filePath,
    required String type,
    Widget? preview,
    String? name,
  }) async {
    if (!mounted) return false;
    int? fileSizeKb;
    try {
      final bytes = File(filePath).lengthSync();
      fileSizeKb = (bytes / 1024).ceil();
    } catch (_) {}
    final result = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(AppStrings.supportTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: preview,
                  ),
                if ((name ?? '').isNotEmpty) ...[
                  if (preview != null) const SizedBox(height: 12),
                  Text(name!, style: Theme.of(context).textTheme.bodyMedium),
                  if (fileSizeKb != null)
                    Text(
                      '$fileSizeKb KB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  type == 'image'
                      ? AppStrings.uploadPhotosText
                      : AppStrings.uploadInvoice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppStrings.sendMessageButtonText),
              ),
            ],
          ),
    );

    return result == true;
  }
}
