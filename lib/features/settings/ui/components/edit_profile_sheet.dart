import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the "edit profile" bottom sheet and, on success, shows a confirmation
/// toast on the calling [context].
Future<void> showEditProfileSheet(
  BuildContext context, {
  required String userId,
  required String currentEmail,
  required String currentName,
  required String currentBio,
}) async {
  final bool? saved = await showKasyBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditProfileSheet(
      userId: userId,
      initialEmail: currentEmail,
      initialName: currentName,
      initialBio: currentBio,
    ),
  );
  if (saved == true && context.mounted) {
    showKasyToast(
      context,
      title: context.t.settings.edit_profile_success,
      tone: KasyToastTone.success,
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final String userId;
  final String initialEmail;
  final String initialName;
  final String initialBio;

  const _EditProfileSheet({
    required this.userId,
    required this.initialEmail,
    required this.initialName,
    required this.initialBio,
  });

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  late final TextEditingController _emailController =
      TextEditingController(text: widget.initialEmail);
  late final TextEditingController _bioController =
      TextEditingController(text: widget.initialBio);
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String bio = _bioController.text.trim();
    if (email.isEmpty || _saving) return; // name & bio can be empty, email cannot.
    setState(() => _saving = true);
    final tr = context.t.settings;
    try {
      await ref.read(userRepositoryProvider).updateProfile(
            userId: widget.userId,
            email: email,
            name: name,
            bio: bio,
          );
      await ref.read(userStateNotifierProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showKasyToast(context, title: tr.edit_profile_error, tone: KasyToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settings;
    return KasyBottomSheet.form(
      title: tr.edit_profile_title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyTextField(
            controller: _nameController,
            label: tr.name_label,
            hint: tr.edit_name_hint,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          KasyTextField(
            controller: _emailController,
            label: tr.email_label,
            hint: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          KasyTextField(
            controller: _bioController,
            label: tr.bio_label,
            hint: tr.bio_hint,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        KasyButton(
          label: tr.edit_profile_save,
          expand: true,
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}
