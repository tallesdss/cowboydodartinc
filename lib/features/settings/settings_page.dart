import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/chrome/chrome_visibility.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/haptics/haptic_feedback_notifier.dart';
import 'package:cowboydodartinc/core/security/biometric_preference_notifier.dart';
import 'package:cowboydodartinc/core/security/biometric_service.dart';
import 'package:cowboydodartinc/core/security/biometric_ui_bundle.dart';
import 'package:cowboydodartinc/core/states/logout_action.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/authentication/repositories/authentication_repository.dart';
import 'package:cowboydodartinc/features/authentication/repositories/exceptions/authentication_exceptions.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_page.dart';
import 'package:cowboydodartinc/features/settings/ui/components/avatar_component.dart';
import 'package:cowboydodartinc/features/settings/ui/components/create_password_sheet.dart';
import 'package:cowboydodartinc/features/settings/ui/components/delete_user_component.dart';
import 'package:cowboydodartinc/features/settings/ui/components/edit_name_sheet.dart';
import 'package:cowboydodartinc/features/settings/ui/components/language_switcher.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_tile.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the admin console on [resolveAdminEntryLocation]: Kanban in debug
/// (when [kDebugAdminOpensKanban] is true) or Overview in release.
///
/// Uses `go`, not `push`: the console is a full-screen shell, and pushing a
/// shell branch OVER the bottom menu leaves the menu (Bart) owning the address
/// bar, so the section's real URL never sticks (the screen shows but the route
/// doesn't change, breaking reload-to-resume). `go` makes the console the
/// top-level route, so its URL is authoritative; "back to app" returns to
/// Settings via [_backToApp]'s `go('/settings')` fallback.
void _openAdminConsole(BuildContext context) {
  context.go(resolveAdminEntryLocation());
}

/// All providers linked to the current account (google/apple/facebook/email/
/// phone), for the "Connected with" row and to decide whether to offer "create
/// password". Empty for guests/unknown.
final _linkedProvidersProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.read(authRepositoryProvider).getLinkedProviders(),
);

/// Social providers the current user can still link to their account (Firebase).
/// Empty on backends that link automatically (Supabase) or aren't wired (API).
final _linkableProvidersProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.read(authRepositoryProvider).linkableSocialProviders(),
);

String _providerDisplayName(String provider) => switch (provider) {
  'google' => 'Google',
  'apple' => 'Apple',
  'facebook' => 'Facebook',
  _ => provider,
};

/// Links a social provider to the current account, then refreshes the lists and
/// shows a toast. Cancelled flows are silently ignored.
Future<void> _linkSocialProvider(
  WidgetRef ref,
  BuildContext context,
  String provider,
) async {
  final tr = context.t.settings;
  try {
    await ref.read(authRepositoryProvider).linkSocialProvider(provider);
    ref.invalidate(_linkableProvidersProvider);
    ref.invalidate(_linkedProvidersProvider);
    await ref.read(userStateNotifierProvider.notifier).refresh();
  } on UserCancelledSignInException {
    return;
  } catch (_) {
    if (context.mounted) {
      showKasyToast(
        context,
        title: tr.link_social_error,
        tone: KasyToastTone.danger,
      );
    }
    return;
  }
  if (context.mounted) {
    showKasyToast(
      context,
      title: tr.link_social_success(provider: _providerDisplayName(provider)),
      tone: KasyToastTone.success,
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.t.settings;
    final user = ref.watch(userStateNotifierProvider).user;
    final isAuthenticated = user is AuthenticatedUserData;
    final String? userId = user.idOrNull;
    final (displayName, displayEmail) = switch (user) {
      final AuthenticatedUserData u => (
        (u.name?.isNotEmpty ?? false) ? u.name! : u.email.split('@').first,
        u.email,
      ),
      _ => (tr.my_account, ''),
    };
    // The real stored name (may be empty) — what the editor seeds with, as
    // opposed to the email-prefix fallback shown for display.
    final String editableName = switch (user) {
      final AuthenticatedUserData u => u.name ?? '',
      _ => '',
    };

    final double width = MediaQuery.sizeOf(context).width;
    // Two-pane master/detail (Vercel/Stripe/Claude) spans the whole desktop
    // range and only collapses to a single column on tablet/phone.
    final bool wide = width >= 1024;
    // The "hide bars on scroll" toggle only makes sense on phones — tablet and
    // desktop use the sidebar, which never hides.
    final bool isPhone = width < 768;

    return KasyOverlayScaffold(
      title: tr.title,
      appBarStyle: KasyAppBarStyle.rootTab,
      hideAppBarOnScroll: true,
      slivers: [
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AccountAvatarHeader(),
                    const SizedBox(height: KasySpacing.md),
                    // Tablet (>= 768) imitates desktop: inline section editor.
                    // Phones keep the bottom-sheet editor.
                    ..._accountBlock(
                      context,
                      inlineEdit: width >= 768,
                      userId: userId,
                      name: displayName,
                      editableName: editableName,
                      email: displayEmail,
                      isAuthenticated: isAuthenticated,
                      onRegister: () => context.push('/signup'),
                      linkedProviders:
                          ref.watch(_linkedProvidersProvider).asData?.value ??
                          const [],
                      linkableProviders:
                          ref.watch(_linkableProvidersProvider).asData?.value ??
                          const [],
                      onLinkProvider: (p) =>
                          _linkSocialProvider(ref, context, p),
                    ),
                    const SizedBox(height: KasySpacing.xl),
                    ..._sections(
                      context,
                      ref,
                      isAuthenticated: isAuthenticated,
                      hasAccount: userId != null,
                      isAdmin: user.isAdmin,
                      isPhone: isPhone,
                    ),
                  ],
                );
              }

              return _SettingsDesktopView(
                userId: userId,
                name: displayName,
                editableName: editableName,
                email: displayEmail,
                isAuthenticated: isAuthenticated,
                isAdmin: user.isAdmin,
                isPhone: isPhone,
              );
            },
          ),
        ),
      ],
    );
  }

  /// The settings sections below the account block — shared by the single
  /// column (mobile/tablet) layout. Ends with sign-out, delete and version.
  List<Widget> _sections(
    BuildContext context,
    WidgetRef ref, {
    required bool isAuthenticated,
    required bool hasAccount,
    required bool isAdmin,
    required bool isPhone,
  }) {
    final tr = context.t.settings;
    return [
      _SectionLabel(tr.section_preferences_label),
      const SizedBox(height: KasySpacing.xs),
      _settingsGroup(_preferenceRows(context, isPhone: isPhone)),
      if (isAuthenticated && !kIsWeb) ...[
        const SizedBox(height: KasySpacing.xl),
        _SectionLabel(tr.section_security_label),
        const SizedBox(height: KasySpacing.xs),
        const SettingsContainer(child: BiometricSwitcher()),
      ],
      const SizedBox(height: KasySpacing.xl),
      _SectionLabel(tr.section_support_label),
      const SizedBox(height: KasySpacing.xs),
      _settingsGroup(_supportRows(context)),
      // Admin entry — only for administrators or in development mode.
      if (isAdmin || kDebugMode) ...[
        const SizedBox(height: KasySpacing.xl),
        _settingsGroup([
          SettingsTile(
            icon: Icons.admin_panel_settings_outlined,
            title: t.admin_console.settings_entry.title,
            onTap: () => _openAdminConsole(context),
          ),
        ]),
        const SizedBox(height: KasySpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: KasySpacing.xs),
          child: Text(
            t.admin_console.settings_entry.caption,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
      ],
      const SizedBox(height: KasySpacing.xxl),
      if (isAuthenticated) ...[
        _settingsGroup([_LogoutRow(onTap: () => confirmLogout(context, ref))]),
        const SizedBox(height: KasySpacing.xl),
      ],
      // Only offer account deletion when there's a real backend account behind
      // it. A guest with no identity has nothing to delete, so the button would
      // just dead-end in an error and trap them on this screen.
      if (hasAccount) ...[
        const DeleteUserButton(),
        const SizedBox(height: KasySpacing.lg),
      ],
      const _VersionLabel(),
    ];
  }
}

// ─── Shared building blocks ────────────────────────────────────────────────

/// Wraps a list of settings rows in a refined card, inserting hairline
/// dividers between them. The card matches the design-system elevated surface
/// (soft shadow + hairline border) instead of the old flat block.
Widget _settingsGroup(List<Widget> rows) {
  return SettingsContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const SettingsDivider(),
          rows[i],
        ],
      ],
    ),
  );
}

/// The Preferences rows, shared between the mobile and desktop layouts.
/// Platform-aware: haptics only on native, hide-on-scroll only on phones.
List<Widget> _preferenceRows(BuildContext context, {required bool isPhone}) {
  final tr = context.t.settings;
  return [
    const ThemeSwitcher(),
    if (!kIsWeb) const HapticFeedbackSwitcher(),
    if (kShowHideChromeOnScrollSetting && isPhone)
      const HideChromeOnScrollSwitcher(),
    const LanguageSwitcher(),
    // Open as inner routes on the nested navigator (NOT context.push, which
    // covers the whole shell via the root navigator): this keeps the sidebar in
    // place on desktop and only swaps the content area — see [subRoutes].
    if (withLocalReminders)
      SettingsTile(
        icon: KasyIcons.notification,
        title: tr.reminders,
        onTap: () => pushSettingsInnerRoute(context, 'reminder'),
      ),
    if (withFeedback)
      SettingsTile(
        icon: KasyIcons.message,
        title: tr.feedback,
        onTap: () => pushSettingsInnerRoute(context, 'feedback'),
      ),
    if (withRevenuecat || withStripe) const _BillingTile(),
  ];
}

/// The Support rows, shared between the mobile and desktop layouts.
List<Widget> _supportRows(BuildContext context) {
  final tr = context.t.settings;
  return [
    SettingsTile(
      icon: KasyIcons.privacy,
      title: tr.privacy,
      onTap: () => launchUrl(Uri.parse('https://kasy.dev/privacy/')),
    ),
    SettingsTile(
      icon: KasyIcons.help,
      title: tr.support,
      onTap: () => launchUrl(Uri.parse('https://kasy.dev/')),
    ),
  ];
}

/// The account identity fields, shared between the mobile and desktop layouts.
/// Signed-in users get an editable Name row and a read-only Email row; guests
/// get a single Register call to action.
List<Widget> _accountFields(
  BuildContext context, {
  required String? userId,
  required String name,
  required String editableName,
  required String email,
  required bool isAuthenticated,
  required VoidCallback onRegister,
  List<String> linkedProviders = const [],
  List<String> linkableProviders = const [],
  void Function(String provider)? onLinkProvider,
}) {
  final tr = context.t.settings;
  if (!isAuthenticated) {
    return [
      KasyButton(
        label: tr.register,
        expand: true,
        variant: KasyButtonVariant.ghost,
        foregroundColor: context.colors.primary,
        onPressed: onRegister,
      ),
    ];
  }
  return [
    _settingsGroup([
      _FieldRow(
        label: tr.name_label,
        value: name,
        onTap: userId == null
            ? null
            : () => showEditNameSheet(
                context,
                userId: userId,
                email: email,
                currentName: editableName,
              ),
      ),
      ..._accountTrailingRows(
        context,
        email: email,
        linkedProviders: linkedProviders,
        linkableProviders: linkableProviders,
        onLinkProvider: onLinkProvider,
      ),
    ]),
  ];
}

/// The Email + provider rows shown below the Name, shared by the phone editor
/// ([_accountFields]) and the tablet/desktop inline editor
/// ([_EditableAccountFields]) so the two never drift.
List<Widget> _accountTrailingRows(
  BuildContext context, {
  required String email,
  required List<String> linkedProviders,
  required List<String> linkableProviders,
  void Function(String provider)? onLinkProvider,
}) {
  final tr = context.t.settings;
  return [
    _FieldRow(label: tr.email_label, value: email),
    if (linkedProviders.isNotEmpty)
      _FieldRow(
        label: tr.connected_with_label,
        value: linkedProviders
            .map(
              (p) => switch (p) {
                'google' => 'Google',
                'apple' => 'Apple',
                'facebook' => 'Facebook',
                'phone' => tr.provider_phone,
                _ => tr.provider_email,
              },
            )
            .join(', '),
      ),
    // Social-only accounts can attach a password (same account) so they can
    // also sign in with email + password. Email/phone users already have one.
    if (linkedProviders.isNotEmpty &&
        !linkedProviders.contains('email') &&
        !linkedProviders.contains('phone'))
      _FieldRow(
        label: tr.create_password_title,
        value: '',
        onTap: () => showCreatePasswordSheet(context),
      ),
    // Firebase: link a social provider (Google/Apple) to this account so it
    // can also be used to sign in. Empty/hidden on Supabase (auto-links).
    for (final provider in linkableProviders)
      _FieldRow(
        label: tr.link_social(provider: _providerDisplayName(provider)),
        value: '',
        onTap: onLinkProvider == null ? null : () => onLinkProvider(provider),
      ),
  ];
}

/// Picks the account block per breakpoint: phones (`inlineEdit == false`) get
/// the bottom-sheet editor; tablet and desktop get the Stripe-style inline
/// section editor ([_EditableAccountFields]). Guests always get the Register
/// call to action from [_accountFields].
List<Widget> _accountBlock(
  BuildContext context, {
  required bool inlineEdit,
  required String? userId,
  required String name,
  required String editableName,
  required String email,
  required bool isAuthenticated,
  required VoidCallback onRegister,
  List<String> linkedProviders = const [],
  List<String> linkableProviders = const [],
  void Function(String provider)? onLinkProvider,
  String? sectionTitle,
}) {
  if (inlineEdit && isAuthenticated) {
    return [
      _EditableAccountFields(
        userId: userId,
        name: name,
        editableName: editableName,
        email: email,
        linkedProviders: linkedProviders,
        linkableProviders: linkableProviders,
        onLinkProvider: onLinkProvider,
        sectionTitle: sectionTitle,
      ),
    ];
  }
  return _accountFields(
    context,
    userId: userId,
    name: name,
    editableName: editableName,
    email: email,
    isAuthenticated: isAuthenticated,
    onRegister: onRegister,
    linkedProviders: linkedProviders,
    linkableProviders: linkableProviders,
    onLinkProvider: onLinkProvider,
  );
}

/// Tablet + desktop account identity block. A Stripe-style section "Edit"
/// control turns the Name into an inline text field; "Save" only enables once it
/// changed and "Cancel" reverts. The avatar stays an independent control (its
/// own camera badge / immediate upload, like GitHub, Vercel and Google), so it
/// is intentionally NOT gated by this edit mode. Phones keep the bottom sheet.
class _EditableAccountFields extends ConsumerStatefulWidget {
  final String? userId;
  final String name;
  final String editableName;
  final String email;
  final List<String> linkedProviders;
  final List<String> linkableProviders;
  final void Function(String provider)? onLinkProvider;

  /// Optional section title rendered on the same row as the Edit control (desktop
  /// layout). When null, the action buttons keep hugging the right edge.
  final String? sectionTitle;

  const _EditableAccountFields({
    required this.userId,
    required this.name,
    required this.editableName,
    required this.email,
    this.linkedProviders = const [],
    this.linkableProviders = const [],
    this.onLinkProvider,
    this.sectionTitle,
  });

  @override
  ConsumerState<_EditableAccountFields> createState() =>
      _EditableAccountFieldsState();
}

class _EditableAccountFieldsState
    extends ConsumerState<_EditableAccountFields> {
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.editableName,
  );
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Re-render so "Save" tracks whether the name actually changed.
    _nameCtrl.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _EditableAccountFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect an external name change (e.g. another device) while idle.
    if (!_editing &&
        !_saving &&
        widget.editableName != oldWidget.editableName) {
      _nameCtrl.text = widget.editableName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onChanged);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _dirty => _nameCtrl.text.trim() != widget.editableName.trim();

  void _cancel() {
    _nameCtrl.text = widget.editableName;
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim();
    final String? userId = widget.userId;
    if (name.isEmpty || _saving || userId == null) return;
    setState(() => _saving = true);
    final tr = context.t.settings;
    try {
      await ref
          .read(userRepositoryProvider)
          .updateEmailAndName(userId: userId, email: widget.email, name: name);
      await ref.read(userStateNotifierProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _saving = false;
        _editing = false;
      });
      showKasyToast(
        context,
        title: tr.edit_name_success,
        tone: KasyToastTone.success,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showKasyToast(
        context,
        title: tr.edit_name_error,
        tone: KasyToastTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: widget.sectionTitle != null ? KasySpacing.xs : 0,
            bottom: widget.sectionTitle != null
                ? KasySpacing.lg
                : KasySpacing.sm,
          ),
          child: Row(
            children: [
              if (widget.sectionTitle != null)
                Expanded(
                  child: Text(
                    widget.sectionTitle!,
                    style: context.kasyTextTheme.sectionTitle.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                )
              else
                const Spacer(),
              // Distinct keys so Flutter does not reconcile "Edit" into "Cancel"
              // (same type + position) and carry over its hover state, which
              // would flash hover on Cancel for one frame when entering edit.
              ..._editing
                  ? [
                      KasyButton(
                        key: const ValueKey('account-edit-cancel'),
                        label: tr.edit_name_cancel,
                        size: KasyButtonSize.small,
                        variant: KasyButtonVariant.ghost,
                        onPressed: _saving ? null : _cancel,
                      ),
                      const SizedBox(width: KasySpacing.sm),
                      KasyButton(
                        key: const ValueKey('account-edit-save'),
                        label: tr.edit_name_save,
                        size: KasyButtonSize.small,
                        isLoading: _saving,
                        onPressed: (_dirty && !_saving) ? _save : null,
                      ),
                    ]
                  : [
                      KasyButton(
                        key: const ValueKey('account-edit-start'),
                        label: tr.edit,
                        size: KasyButtonSize.small,
                        variant: KasyButtonVariant.ghost,
                        icon: KasyIcons.edit,
                        onPressed: widget.userId == null
                            ? null
                            : () => setState(() => _editing = true),
                      ),
                    ],
            ],
          ),
        ),
        _settingsGroup([
          if (_editing)
            _InlineFieldRow(
              label: tr.name_label,
              controller: _nameCtrl,
              hint: tr.edit_name_hint,
              enabled: !_saving,
              onSubmitted: _save,
            )
          else
            _FieldRow(label: tr.name_label, value: widget.name),
          ..._accountTrailingRows(
            context,
            email: widget.email,
            linkedProviders: widget.linkedProviders,
            linkableProviders: widget.linkableProviders,
            onLinkProvider: widget.onLinkProvider,
          ),
        ]),
      ],
    );
  }
}

/// A settings row whose value is an inline editable field: the label sits on the
/// left (like [_FieldRow]) and a [KasyTextField] fills the rest.
class _InlineFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final VoidCallback onSubmitted;

  const _InlineFieldRow({
    required this.label,
    required this.controller,
    required this.onSubmitted,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: context.kasyTextTheme.listRowTitle.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          const Spacer(),
          // Mirror the app bar search field: flat (no shadow), compact padding
          // and the same width, sitting on the right where the value normally is.
          SizedBox(
            width: kasyAppBarApplicationSearchWidth,
            child: KasyTextField(
              variant: KasyTextFieldVariant.flat,
              controller: controller,
              hint: hint,
              enabled: enabled,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmitted(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subscription/billing entry in the Preferences section.
/// - Not subscribed → "Premium" (taps into the paywall).
/// - Subscribed      → "Cobrança" + plan name on the right (taps into billing).
class _BillingTile extends ConsumerWidget {
  const _BillingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(userStateNotifierProvider).subscription;
    final tr = context.t;

    if (sub is SubscriptionStateData) {
      final planName = sub.activeOffer?.title ?? tr.activePremium.plan_fallback;
      return SettingsTile(
        icon: KasyIcons.payment,
        title: tr.settings.billing,
        trailingLabel: planName,
        onTap: () => context.push('/premium'),
      );
    }

    return SettingsTile(
      icon: KasyIcons.payment,
      title: tr.settings.premium,
      onTap: () => context.push('/premium'),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    // Quieter than before and aligned with the sidebar's section labels: small,
    // gently tracked, muted — so it never out-shouts the content it heads.
    return Padding(
      padding: const EdgeInsets.only(left: KasySpacing.xs),
      child: Text(
        label,
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: context.colors.muted,
        ),
      ),
    );
  }
}

/// Grouped surface for settings rows — the design-system elevated card with a
/// settings-density radius.
class SettingsContainer extends StatelessWidget {
  final Widget child;

  const SettingsContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      borderRadius: BorderRadius.circular(KasyRadius.lg),
      // No card padding: each row carries its own inset so the press/hover
      // highlight spans the full card width (clipped to the rounded corners),
      // instead of a pill floating inside a white margin.
      child: child,
    );
  }
}

/// A label + value row used in the Account section. With [onTap] it is an
/// editable field (trailing chevron, keyboard-focusable); without it the value
/// is read-only (e.g. the email).
class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _FieldRow({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      children: [
        Text(
          label,
          style: context.kasyTextTheme.listRowTitle.copyWith(
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(width: KasySpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.kasyTextTheme.listRowValue.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: KasySpacing.xs),
          const SettingsListChevron(),
        ],
      ],
    );
    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        child: row,
      );
    }
    return KasyHover(
      onTap: onTap!,
      focusable: true,
      // Rectangular highlight (default): the card clips the rounded ends.
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: row,
    );
  }
}

/// The avatar header shown at the top of the Account block on the single-column
/// (mobile/tablet) layout. Tapping the avatar changes the photo; identity text
/// lives in the editable fields below, so nothing is shown twice.
class _AccountAvatarHeader extends StatelessWidget {
  const _AccountAvatarHeader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: KasySpacing.sm),
        child: EditableUserAvatar(diameter: 80),
      ),
    );
  }
}

// ─── Desktop (≥1024px): SaaS-style master/detail ──────────────────────────
//
// A left nav lists the settings sections; the right pane shows the selected
// one. Mirrors the layout of Vercel / Stripe / Claude settings. The phone and
// tablet layout (single column) is untouched.

enum _DesktopSection { account, preferences, security, support, admin }

/// Title-cases an all-caps section label (e.g. "PREFERENCES" → "Preferences")
/// in a way that's safe across locales (single-word labels only).
String _titleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

(IconData, String) _sectionMeta(BuildContext context, _DesktopSection section) {
  final tr = context.t.settings;
  return switch (section) {
    _DesktopSection.account => (KasyIcons.person, tr.my_account),
    _DesktopSection.preferences => (
      KasyIcons.settings,
      _titleCase(tr.section_preferences_label),
    ),
    _DesktopSection.security => (
      KasyIcons.security,
      _titleCase(tr.section_security_label),
    ),
    _DesktopSection.support => (
      KasyIcons.help,
      _titleCase(tr.section_support_label),
    ),
    _DesktopSection.admin => (
      Icons.admin_panel_settings_outlined,
      t.admin_console.settings_entry.title,
    ),
  };
}

class _SettingsDesktopView extends ConsumerStatefulWidget {
  final String? userId;
  final String name;
  final String editableName;
  final String email;
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isPhone;

  const _SettingsDesktopView({
    required this.userId,
    required this.name,
    required this.editableName,
    required this.email,
    required this.isAuthenticated,
    required this.isAdmin,
    required this.isPhone,
  });

  @override
  ConsumerState<_SettingsDesktopView> createState() =>
      _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends ConsumerState<_SettingsDesktopView> {
  _DesktopSection _selected = _DesktopSection.account;

  void _select(_DesktopSection s) => setState(() => _selected = s);

  List<_DesktopSection> get _sections => <_DesktopSection>[
    _DesktopSection.account,
    _DesktopSection.preferences,
    if (widget.isAuthenticated && !kIsWeb) _DesktopSection.security,
    _DesktopSection.support,
    if (widget.isAdmin || kDebugMode) _DesktopSection.admin,
  ];

  @override
  Widget build(BuildContext context) {
    final List<_DesktopSection> sections = _sections;
    if (!sections.contains(_selected)) _selected = sections.first;

    final Widget pane = _DesktopDetail(
      section: _selected,
      userId: widget.userId,
      name: widget.name,
      editableName: widget.editableName,
      email: widget.email,
      isAuthenticated: widget.isAuthenticated,
      isPhone: widget.isPhone,
    );

    const double navWidth = 220;
    const double gap = KasySpacing.xl;
    const double detailWidth = 560;
    const double groupWidth = navWidth + gap + detailWidth;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: KasySpacing.lg,
          bottom: KasySpacing.xxl,
        ),
        // Center the nav + detail as ONE unit so the whitespace is equal on
        // both sides (Linear/Notion settings), instead of pinning the nav left
        // and leaving the right empty. Settings are forms, so the detail keeps
        // a comfortable reading width rather than stretching wide. On tight
        // desktop widths the detail fills the remaining space so it never
        // overflows.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool fits = constraints.maxWidth >= groupWidth;
            return Row(
              mainAxisSize: fits ? MainAxisSize.min : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: navWidth,
                  child: _DesktopNav(
                    sections: sections,
                    selected: _selected,
                    name: widget.name,
                    email: widget.email,
                    onSelect: _select,
                  ),
                ),
                const SizedBox(width: gap),
                if (fits)
                  SizedBox(width: detailWidth, child: pane)
                else
                  Expanded(child: pane),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DesktopNav extends StatelessWidget {
  final List<_DesktopSection> sections;
  final _DesktopSection selected;
  final String name;
  final String email;
  final ValueChanged<_DesktopSection> onSelect;

  const _DesktopNav({
    required this.sections,
    required this.selected,
    required this.name,
    required this.email,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.sm,
            KasySpacing.sm,
            KasySpacing.sm,
            KasySpacing.md,
          ),
          child: Row(
            children: [
              const EditableUserAvatar(diameter: 64),
              const SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final _DesktopSection s in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: KasySpacing.xs),
            child: _NavTile(
              section: s,
              selected: s == selected,
              onTap: () => onSelect(s),
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final _DesktopSection section;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final (IconData icon, String label) = _sectionMeta(context, section);
    final Color fg = selected ? c.onSurface : c.muted;

    // Same interaction model as KasySidebar: KasyHover (MouseRegion + animated
    // fill, no Material ripple) over a static selected background.
    return KasyHover(
      borderRadius: KasyRadius.smBorderRadius,
      hoverColor: c.surfaceNeutralSoft,
      pressColor: c.onSurface,
      focusable: true,
      focusGapColor: c.surface,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.smd,
          vertical: KasySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? c.surfaceNeutralSoft : Colors.transparent,
          borderRadius: KasyRadius.smBorderRadius,
        ),
        child: Row(
          children: [
            Icon(icon, size: KasyIconSize.rowLeading, color: fg),
            const SizedBox(width: KasySpacing.sm),
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopDetail extends ConsumerWidget {
  final _DesktopSection section;
  final String? userId;
  final String name;
  final String editableName;
  final String email;
  final bool isAuthenticated;
  final bool isPhone;

  const _DesktopDetail({
    required this.section,
    required this.userId,
    required this.name,
    required this.editableName,
    required this.email,
    required this.isAuthenticated,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (_, String title) = _sectionMeta(context, section);

    // The authenticated account section renders its title inline with the Edit
    // control (see [_EditableAccountFields]), so skip the standalone heading.
    final bool titleInContent =
        section == _DesktopSection.account && isAuthenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!titleInContent)
          Padding(
            padding: const EdgeInsets.only(
              left: KasySpacing.xs,
              bottom: KasySpacing.lg,
            ),
            // Reserve the same height as the Account header (which carries the
            // small Edit button) so the title stays at one vertical position as
            // you switch sections instead of jumping.
            child: SizedBox(
              height: KasyButton.smallHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: context.kasyTextTheme.sectionTitle.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ..._content(context, ref),
      ],
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref) {
    switch (section) {
      case _DesktopSection.account:
        return _accountContent(context, ref);
      case _DesktopSection.preferences:
        return [_settingsGroup(_preferenceRows(context, isPhone: isPhone))];
      case _DesktopSection.security:
        return const [SettingsContainer(child: BiometricSwitcher())];
      case _DesktopSection.support:
        return [_settingsGroup(_supportRows(context))];
      case _DesktopSection.admin:
        return [
          _settingsGroup([
            SettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: t.admin_console.settings_entry.title,
              onTap: () => _openAdminConsole(context),
            ),
          ]),
          const SizedBox(height: KasySpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: KasySpacing.xs),
            child: Text(
              t.admin_console.settings_entry.caption,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
              ),
            ),
          ),
        ];
    }
  }

  List<Widget> _accountContent(BuildContext context, WidgetRef ref) {
    final (_, String title) = _sectionMeta(context, section);
    return [
      // Desktop is always wide (>= 1024): inline section editor.
      ..._accountBlock(
        context,
        inlineEdit: true,
        sectionTitle: isAuthenticated ? title : null,
        userId: userId,
        name: name,
        editableName: editableName,
        email: email,
        isAuthenticated: isAuthenticated,
        onRegister: () => context.push('/signup'),
        linkedProviders:
            ref.watch(_linkedProvidersProvider).asData?.value ?? const [],
        linkableProviders:
            ref.watch(_linkableProvidersProvider).asData?.value ?? const [],
        onLinkProvider: (p) => _linkSocialProvider(ref, context, p),
      ),
      if (isAuthenticated) ...[
        const SizedBox(height: KasySpacing.xl),
        _settingsGroup([_LogoutRow(onTap: () => confirmLogout(context, ref))]),
      ],
      // Only when there's a real backend account to delete (see mobile layout).
      if (userId != null) ...[
        const SizedBox(height: KasySpacing.xl),
        const DeleteUserButton(),
      ],
      const SizedBox(height: KasySpacing.lg),
      const _VersionLabel(),
    ];
  }
}

/// A danger-tinted "Sign out" row used in the Account section.
class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return KasyHover(
      // Match the card radius so the full-bleed press fill hugs the rounded
      // corners exactly (this row is the sole child of its card).
      borderRadius: KasyRadius.lgBorderRadius,
      pressColor: context.colors.error,
      focusable: true,
      focusGapColor: context.colors.surface,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        child: Row(
          children: [
            Icon(
              KasyIcons.logout,
              size: KasyIconSize.rowLeading,
              color: context.colors.error,
            ),
            const SizedBox(width: KasySpacing.sm),
            Text(
              context.t.settings.logout,
              style: context.kasyTextTheme.listRowTitle.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionLabel extends StatefulWidget {
  const _VersionLabel();

  @override
  State<_VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<_VersionLabel> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _version,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class BiometricSwitcher extends ConsumerWidget {
  const BiometricSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(biometricPreferenceProvider);
    final tr = context.t.settings;
    final platform = Theme.of(context).platform;
    final slotAsync = ref.watch(biometricCopySlotFamily(platform));
    final subtitle = slotAsync.when(
      data: (slot) => BioBundle.fromSlot(context, slot).settingsSubtitle,
      loading: () => BioBundle.fallbackForPlatform(context).settingsSubtitle,
      error: (_, _) => BioBundle.fallbackForPlatform(context).settingsSubtitle,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSwitchTile(
          icon: KasyIcons.fingerprint,
          title: tr.biometric_title,
          value: isEnabled,
          onChanged: (value) => _onChanged(context, ref, value),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: KasySpacing.md + KasyIconSize.rowLeading + KasySpacing.sm,
            bottom: KasySpacing.xs,
          ),
          child: Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (!value) {
      _confirmDisable(context, ref);
      return;
    }
    await _enableBiometric(context, ref);
  }

  Future<void> _enableBiometric(BuildContext context, WidgetRef ref) async {
    final tr = context.t.settings;
    final platform = Theme.of(context).platform;
    final slot = await ref.read(biometricCopySlotFamily(platform).future);
    if (!context.mounted) return;
    final bundle = BioBundle.fromSlot(context, slot);
    final unavailableMsg = bundle.unavailableMessage;
    final reason = bundle.enableReason;

    final service = ref.read(biometricServiceProvider);
    final isAvailable = await service.isAvailable();
    if (!isAvailable) {
      if (!context.mounted) return;
      showKasyToast(
        context,
        title: unavailableMsg,
        tone: KasyToastTone.warning,
      );
      return;
    }
    final authenticated = await service.authenticate(localizedReason: reason);
    if (!context.mounted) return;
    if (!authenticated) {
      showKasyToast(
        context,
        title: tr.biometric_not_enabled_message,
        tone: KasyToastTone.warning,
      );
      return;
    }
    await ref.read(biometricPreferenceProvider.notifier).setEnabled(true);
  }

  void _confirmDisable(BuildContext context, WidgetRef ref) {
    final tr = context.t.settings;
    showKasyConfirmDialog(
      context,
      title: tr.biometric_disable_title,
      message: tr.biometric_disable_message,
      cancelLabel: tr.biometric_disable_cancel,
      confirmLabel: tr.biometric_disable_confirm,
      onConfirm: () {
        ref.read(biometricPreferenceProvider.notifier).setEnabled(false);
      },
    );
  }
}

class HapticFeedbackSwitcher extends ConsumerWidget {
  const HapticFeedbackSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(hapticFeedbackProvider);
    return SettingsSwitchTile(
      icon: KasyIcons.phoneAndroid,
      title: context.t.settings.haptic_feedback_title,
      value: isEnabled,
      onChanged: (_) => ref.read(hapticFeedbackProvider.notifier).toggle(),
    );
  }
}

class HideChromeOnScrollSwitcher extends ConsumerWidget {
  const HideChromeOnScrollSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(hideChromeOnScrollProvider);
    return SettingsSwitchTile(
      icon: KasyIcons.eyeOff,
      title: context.t.settings.hide_chrome_on_scroll_title,
      value: isEnabled,
      onChanged: (_) => ref.read(hideChromeOnScrollProvider.notifier).toggle(),
    );
  }
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  // Tab order mirrors the trailing pill: system, light, dark.
  static const List<ThemeMode> _modes = <ThemeMode>[
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settings;
    final theme = ThemeProvider.of(context);
    final items = <KasyTabItem>[
      KasyTabItem(
        icon: KasyIcons.monitor,
        semanticLabel: tr.theme_option_system,
      ),
      KasyTabItem(
        icon: KasyIcons.lightMode,
        semanticLabel: tr.theme_option_light,
      ),
      KasyTabItem(
        icon: KasyIcons.darkMode,
        semanticLabel: tr.theme_option_dark,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: Row(
        children: [
          Icon(
            KasyIcons.palette,
            size: KasyIconSize.rowLeading,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Text(
              tr.theme_title,
              style: context.kasyTextTheme.listRowTitle.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          KasyTabs.items(
            items: items,
            selectedIndex: _modes.indexOf(theme.mode),
            onTabSelected: (i) => theme.setMode(_modes[i]),
          ),
        ],
      ),
    );
  }
}
