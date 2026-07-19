import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the "create password" flow. Lets a social-only user (Google, Apple, ...)
/// set a password so they can also sign in with email + password. The account
/// stays the same (no duplicate). Shows a success toast on the calling [context]
/// when done.
///
/// Mobile/tablet keep the bottom sheet (touch). Desktop (>= 1024) shows the same
/// form inside a centered [KasyDialog] instead of a full-width sheet.
Future<void> showCreatePasswordSheet(BuildContext context) async {
  final bool isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  // Start the surface synchronously (before the await) so context isn't used
  // across the async gap; only context.mounted guards the toast afterwards.
  final Future<bool?> pending = isDesktop
      ? showKasyBlurDialog<bool>(
          context: context,
          builder: (_) => const _CreatePasswordForm(asDialog: true),
        )
      : showKasyBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _CreatePasswordForm(asDialog: false),
        );
  final bool? saved = await pending;
  if (saved == true && context.mounted) {
    showKasyToast(
      context,
      title: context.t.settings.create_password_success,
      tone: KasyToastTone.success,
    );
  }
}

class _CreatePasswordForm extends ConsumerStatefulWidget {
  /// When true, render inside a centered [KasyDialog] (desktop); otherwise a
  /// [KasyBottomSheet] (mobile/tablet). The form logic is identical either way.
  final bool asDialog;

  const _CreatePasswordForm({required this.asDialog});

  @override
  ConsumerState<_CreatePasswordForm> createState() =>
      _CreatePasswordFormState();
}

class _CreatePasswordFormState extends ConsumerState<_CreatePasswordForm> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  static const int _minLength = 6;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final tr = context.t.settings;
    final password = _passwordController.text;
    if (password.length < _minLength) {
      setState(() => _error = tr.create_password_too_short);
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = tr.create_password_mismatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).setPassword(password);
      if (!mounted) return;
      // Toast is shown by the launcher on the page context (this surface's
      // context is gone right after the pop).
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showKasyToast(
        context,
        title: tr.create_password_error,
        tone: KasyToastTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settings;
    final List<Widget> fields = [
      Text(
        tr.create_password_subtitle,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.muted,
        ),
      ),
      const SizedBox(height: KasySpacing.md),
      KasyTextField(
        controller: _passwordController,
        label: tr.create_password_field,
        contentType: KasyTextFieldContentType.password,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: KasySpacing.sm),
      KasyTextField(
        controller: _confirmController,
        label: tr.create_password_confirm_label,
        contentType: KasyTextFieldContentType.password,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      if (_error != null) ...[
        const SizedBox(height: KasySpacing.sm),
        Text(
          _error!,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.error,
          ),
        ),
      ],
    ];

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fields,
    );

    if (widget.asDialog) {
      // Desktop: centered dialog (title, fields, Cancel + Save), no full-width
      // sheet sliding from the bottom.
      return KasyDialog(
        title: tr.create_password_title,
        showCloseButton: false,
        body: body,
        actionsAxis: Axis.horizontal,
        actions: [
          KasyButton(
            label: tr.edit_name_cancel,
            variant: KasyButtonVariant.outline,
            expand: true,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          KasyButton(
            label: tr.edit_name_save,
            expand: true,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      );
    }

    return KasyBottomSheet(
      title: tr.create_password_title,
      addKeyboardInset: true,
      body: body,
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
