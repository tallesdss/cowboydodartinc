import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maximum characters allowed in a single chat message.
const int kAiChatMaxMessageLength = 2000;

/// Unified chat bar: primary [KasyTextField] shell (surface, border, shadow) + send orb inside.
class AiChatComposer extends StatefulWidget {
  const AiChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isReplying,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isReplying;

  static const int _maxLines = 5;

  @override
  State<AiChatComposer> createState() => _AiChatComposerState();
}

class _AiChatComposerState extends State<AiChatComposer> {
  bool _canSend = false;

  // Owns the field focus so we can intercept hardware Enter: plain Enter sends,
  // Shift+Enter inserts a newline (the standard chat-composer behaviour). On
  // touch keyboards (no hardware key event) the return key keeps inserting a
  // newline and the send orb is used, so mobile is unchanged.
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _onKeyEvent);

  @override
  void initState() {
    super.initState();
    _canSend = _hasSendableText(widget.controller.text);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final bool isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;
    // Shift+Enter falls through to the field and inserts a newline.
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    _handleSend();
    return KeyEventResult.handled;
  }

  bool _hasSendableText(String value) {
    final String trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.length <= kAiChatMaxMessageLength;
  }

  void _onTextChanged() {
    final bool nextCanSend = _hasSendableText(widget.controller.text);
    if (nextCanSend == _canSend) return;
    setState(() => _canSend = nextCanSend);
  }

  void _handleSend() {
    if (!_canSend || widget.isReplying) return;
    widget.onSend();
    setState(() => _canSend = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = !widget.isReplying;
    final BorderRadius shellRadius = BorderRadius.circular(KasyRadius.xl);
    final Color borderColor = KasyShadows.inputFieldRestingBorder(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: shellRadius,
        border: Border.all(color: borderColor),
        boxShadow: kIsWeb
            ? null
            : KasyShadows.inputField(context, enabled: enabled),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KasySpacing.md,
          KasySpacing.xs,
          KasySpacing.sm,
          KasySpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: KasyTextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: enabled,
                variant: KasyTextFieldVariant.embedded,
                hint: t.ai_chat.hint,
                minLines: 1,
                maxLines: AiChatComposer._maxLines,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(kAiChatMaxMessageLength),
                ],
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            if (_canSend || widget.isReplying) ...[
              const SizedBox(width: KasySpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: KasyButton.iconOnly(
                  icon: KasyIcons.arrowUp,
                  isLoading: widget.isReplying,
                  onPressed: _canSend && !widget.isReplying ? _handleSend : null,
                  size: KasyButtonSize.small,
                  iconOnlyLayoutExtent: 36,
                  iconGlyphSize: 18,
                  semanticLabel: t.ai_chat.hint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
