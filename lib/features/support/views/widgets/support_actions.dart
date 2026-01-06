import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/input_field.dart';
import 'package:haraj_adan_app/features/support/controllers/support_detail_controller.dart';

class SupportActions extends StatefulWidget {
  final SupportDetailController controller;

  const SupportActions({super.key, required this.controller});

  @override
  State<SupportActions> createState() => _SupportActionsState();
}

class _SupportActionsState extends State<SupportActions> {
  final _textController = TextEditingController();

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: InputField(
                controller: _textController,
                hintText: AppStrings.typeHere,
                keyboardType: TextInputType.text,
                onEditingComplete: () => _send(),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isSending = widget.controller.isSending.value;
              return Material(
                shape: const CircleBorder(),
                color: isSending
                    ? theme.disabledColor.withOpacity(0.3)
                    : theme.colorScheme.primary,
                child: InkWell(
                  onTap: isSending ? null : _send,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
Future<void> _send() async {
  final text = _textController.text.trim();
  if (text.isEmpty) return;

   widget.controller.sendText(text);
  _textController.clear();
  FocusScope.of(context).unfocus();
}

}
