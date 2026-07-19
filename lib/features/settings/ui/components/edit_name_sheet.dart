import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the "edit name" bottom sheet and, on success, shows a confirmation
/// toast on the calling [context]. The email is intentionally read-only — only
/// the display name can be changed here.
Future<void> showEditNameSheet(
  BuildContext context, {
  required String userId,
  required String email,
  required String currentName,
}) async {
  final bool? saved = await showKasyBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditNameSheet(
      userId: userId,
      email: email,
      initialName: currentName,
    ),
  );
  if (saved == true && context.mounted) {
    showKasyToast(
      context,
      title: context.t.settings.edit_name_success,
      tone: KasyToastTone.success,
    );
  }
}

class _EditNameSheet extends ConsumerStatefulWidget {
  final String userId;
  final String email;
  final String initialName;

  const _EditNameSheet({
    required this.userId,
    required this.email,
    required this.initialName,
  });

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final tr = context.t.settings;
    try {
      await ref.read(userRepositoryProvider).updateEmailAndName(
            userId: widget.userId,
            email: widget.email,
            name: name,
          );
      await ref.read(userStateNotifierProvider.notifier).refresh();
      if (!mounted) return;
      // The success toast is shown by the launcher on the page context, since
      // this sheet's context is gone right after the pop.
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showKasyToast(context, title: tr.edit_name_error, tone: KasyToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settings;
    return KasyBottomSheet.form(
      title: tr.edit_name_title,
      body: KasyTextField(
        controller: _controller,
        label: tr.name_label,
        hint: tr.edit_name_hint,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        KasyButton(
          label: tr.edit_name_save,
          expand: true,
          isLoading: _saving,
          onPressed: _save,
        ),
        KasyButton(
          label: tr.edit_name_cancel,
          variant: KasyButtonVariant.ghost,
          expand: true,
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
