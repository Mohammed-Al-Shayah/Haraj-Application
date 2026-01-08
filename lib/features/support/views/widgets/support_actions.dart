import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';
import 'package:image_picker/image_picker.dart';

class SupportActions extends StatefulWidget {
  final SupportDetailController controller;

  const SupportActions({super.key, required this.controller});

  @override
  State<SupportActions> createState() => _SupportActionsState();
}

class _SupportActionsState extends State<SupportActions> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Obx(() {
        final isSending = widget.controller.isSending.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              _iconButton(
                AppAssets.galleryIcon,
                isSending ? null : _pickImage,
              ),
              const SizedBox(width: 4),
              _iconButton(
                AppAssets.folderIcon,
                isSending ? null : _pickFile,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputField(
                  controller: _textController,
                  hintText: AppStrings.typeHere,
                  keyboardType: TextInputType.text,
                  onEditingComplete: _sendText,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                shape: const CircleBorder(),
                color: isSending
                    ? theme.disabledColor.withOpacity(0.3)
                    : theme.colorScheme.primary,
                child: InkWell(
                  onTap: isSending ? null : _sendText,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _iconButton(String assetPath, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(assetPath, width: 22, height: 22),
        ),
      ),
    );
  }

  Future<void> _sendText() async {
    final trimmed = _textController.text.trim();
    if (trimmed.isEmpty) return;

    widget.controller.sendText(trimmed);
    _textController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (result == null) return;
    if (!mounted) return;

    final confirmed = await _confirmSendMedia(
      context: context,
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

    await widget.controller.uploadMedia(filePath: result.path, type: 'image');
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      withData: false,
      allowMultiple: false,
      type: FileType.any,
    );
    final file = res?.files.single;
    if (file?.path == null) return;
    if (!mounted) return;

    final ext = file!.extension?.toLowerCase() ?? '';
    final isImage = ['png', 'jpg', 'jpeg', 'heic', 'webp', 'gif'].contains(ext);
    final isPdf = ext == 'pdf';

    final preview = isImage
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
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                size: 28,
                color: isPdf ? Colors.red : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(file.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final confirmed = await _confirmSendMedia(
      context: context,
      filePath: file.path!,
      type: isImage ? 'image' : 'file',
      preview: preview,
      name: file.name,
    );
    if (!confirmed) return;

    await widget.controller.uploadMedia(
      filePath: file.path!,
      type: isImage ? 'image' : 'file',
    );
  }

  Future<bool> _confirmSendMedia({
    required BuildContext context,
    required String filePath,
    required String type,
    Widget? preview,
    String? name,
  }) async {
    int? fileSizeKb;
    try {
      final bytes = File(filePath).lengthSync();
      fileSizeKb = (bytes / 1024).ceil();
    } catch (_) {}

    final dialog = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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

    return dialog == true;
  }
}
