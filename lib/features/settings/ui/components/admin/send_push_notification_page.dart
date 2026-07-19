import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_drop_down.dart';
import 'package:cowboydodartinc/components/kasy_tabs.dart';
import 'package:cowboydodartinc/components/kasy_text_area.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/dev_inspector/dev_inspector.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/features/notifications/api/notifications_api.dart';
import 'package:cowboydodartinc/features/notifications/notifications_ui_constants.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/send_push_notifier.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Same canonical pattern the auth `Email` value object validates against — an
/// address must be well-formed before it can join the recipient list.
final RegExp _emailPattern = RegExp(
  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
);

bool _isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

/// Default push destination: the in-app notifications list. Mirrors the
/// fallback in `Notification.onTap` (no route sent → `/notifications`).
const String _defaultRoute = '/notifications';

class SendPushNotificationPage extends ConsumerStatefulWidget {
  const SendPushNotificationPage({super.key});

  @override
  ConsumerState<SendPushNotificationPage> createState() =>
      _SendPushNotificationPageState();
}

class _SendPushNotificationPageState
    extends ConsumerState<SendPushNotificationPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Explicit FocusNodes for all fields keeps the keyboard open when switching.
  final _emailFocus = FocusNode();
  final _titleFocus = FocusNode();
  final _bodyFocus = FocusNode();
  final _imageFocus = FocusNode();

  // Drives the narrow-layout sticky preview: the banner rides the scroll
  // upward, then locks at the top while the form keeps scrolling under it.
  final _scrollController = ScrollController();

  // Opens on the first tab ("everyone") by default — the conventional segmented
  // control behaviour; the admin switches to "specific" to target e-mails.
  bool _sendToAll = true;
  final List<String> _emails = [];
  String _appName = '';

  /// Page the app opens when the user taps the notification. Defaults to the
  /// notifications list (the same fallback `Notification.onTap` uses when no
  /// route is sent), and the admin can repoint it to any available page.
  String _route = _defaultRoute;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appName = info.appName);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _imageCtrl.dispose();
    _emailCtrl.dispose();
    _emailFocus.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    _imageFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// The "add" button stays disabled until the field holds a well-formed,
  /// not-yet-listed e-mail — so it never adds blanks, malformed strings, or
  /// duplicates (the Enter key shares this guard via [_addEmail]).
  bool get _canAddEmail {
    final email = _emailCtrl.text.trim();
    return _isValidEmail(email) && !_emails.contains(email);
  }

  void _addEmail() {
    if (!_canAddEmail) return;
    setState(() {
      _emails.add(_emailCtrl.text.trim());
      _emailCtrl.clear();
    });
    _emailFocus.requestFocus();
  }

  void _removeEmail(String email) {
    setState(() => _emails.remove(email));
  }

  /// Clears every field after a successful send. The screen is a console
  /// section (reached from the sidebar), so there is nothing to pop — we reset
  /// in place so the admin can fire another notification right away.
  void _resetForm() {
    _titleCtrl.clear();
    _bodyCtrl.clear();
    _imageCtrl.clear();
    _emailCtrl.clear();
    setState(() {
      _emails.clear();
      _sendToAll = true;
      _route = _defaultRoute;
    });
  }

  bool get _canSend {
    if (_titleCtrl.text.trim().isEmpty) return false;
    if (_bodyCtrl.text.trim().isEmpty) return false;
    if (!_sendToAll && _emails.isEmpty) return false;
    return true;
  }

  void _onSendAttempt() {
    final tr = t.settings.admin;
    final String msg;
    if (!_sendToAll && _emails.isEmpty) {
      msg = tr.send_push_no_emails;
    } else {
      msg = tr.send_push_required;
    }
    ref.read(toastProvider).error(title: tr.send_push_title, text: msg);
  }

  Future<void> _send() async {
    await ref.read(sendPushProvider.notifier).send(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          imageUrl: _imageCtrl.text.trim().isEmpty
              ? null
              : _imageCtrl.text.trim(),
          emails: List.from(_emails),
          sendToAll: _sendToAll,
          route: _route,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendPushProvider);
    final tr = t.settings.admin;

    ref.listen<AsyncValue<void>>(sendPushProvider, (prev, next) {
      if (next is AsyncError) {
        final err = next.error;
        final msg = err is UsersNotFoundError
            ? tr.send_push_user_not_found(email: err.toString())
            : err.toString();
        ref.read(toastProvider).error(title: tr.send_push_title, text: msg);
        ref.read(sendPushProvider.notifier).reset();
      } else if (prev is AsyncLoading && next is AsyncData) {
        ref
            .read(toastProvider)
            .success(title: tr.send_push_title, text: tr.send_push_success);
        _resetForm();
      }
    });

    Widget buildSubmit({required bool expand}) {
      final KasyButton button = KasyButton(
        label: tr.send_push_send_button,
        expand: expand,
        isLoading: state is AsyncLoading,
        onPressed: _canSend ? _send : null,
      );
      // Disabled: tapping explains what's missing instead of doing nothing.
      return _canSend
          ? button
          : GestureDetector(onTap: _onSendAttempt, child: button);
    }

    // Recipients: a segmented audience selector (everyone / specific) over the
    // e-mail list, instead of a lone switch — reads as a deliberate choice.
    final Widget recipients = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyTabs(
          tabs: [tr.send_push_audience_all, tr.send_push_audience_specific],
          selectedIndex: _sendToAll ? 0 : 1,
          onTabSelected: (i) => setState(() => _sendToAll = i == 0),
          mode: KasyTabsMode.fill,
        ),
        const SizedBox(height: KasySpacing.md),
        if (_sendToAll)
          Text(
            tr.send_push_audience_all_hint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              height: 1.35,
            ),
          )
        else
          _EmailsSection(
            emails: _emails,
            controller: _emailCtrl,
            focusNode: _emailFocus,
            onAdd: _addEmail,
            onRemove: _removeEmail,
            // Rebuild as the admin types so the add button enables/disables live.
            onChanged: () => setState(() {}),
            canAdd: _canAddEmail,
            label: tr.send_push_email_label,
            hint: tr.send_push_email_hint,
          ),
      ],
    );

    final Widget contentFields = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyTextField(
          label: tr.send_push_title_label,
          hint: tr.send_push_title_hint,
          controller: _titleCtrl,
          focusNode: _titleFocus,
          maxLength: 64,
          showRequiredIndicator: true,
          // Secondary fill contrasts against the surface-colored section card —
          // the primary (surface) fill would blend white-on-white.
          variant: KasyTextFieldVariant.secondary,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          onEditingComplete: () => _bodyFocus.requestFocus(),
        ),
        const SizedBox(height: KasySpacing.md),
        KasyTextArea(
          label: tr.send_push_body_label,
          hint: tr.send_push_body_hint,
          controller: _bodyCtrl,
          focusNode: _bodyFocus,
          maxLength: kNotificationPushBodyMaxLength,
          showRequiredIndicator: true,
          variant: KasyTextFieldVariant.secondary,
          minLines: 2,
          maxLines: kNotificationListBodyMaxLines,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: KasySpacing.md),
        KasyTextField(
          label: tr.send_push_image_label,
          hint: tr.send_push_image_hint,
          controller: _imageCtrl,
          focusNode: _imageFocus,
          variant: KasyTextFieldVariant.secondary,
          onChanged: (_) => setState(() {}),
          // Last text input on the form — close the keyboard on submit.
          textInputAction: TextInputAction.done,
          onEditingComplete: () => _imageFocus.unfocus(),
        ),
      ],
    );

    // Pick the landing page from the routes this build actually ships (the
    // optional ones are feature-flagged, exactly like the router), instead of
    // typing a raw path. Leaving the default sends the user to /notifications.
    final Widget advancedFields = KasyDropDown<String>(
      label: tr.send_push_route_label,
      description: tr.send_push_route_description,
      value: _route,
      variant: KasyTextFieldVariant.secondary,
      onChanged: (route) => setState(() => _route = route),
      items: <KasyDropDownItem<String>>[
        KasyDropDownItem(
          value: '/notifications',
          label: tr.send_push_route_notifications,
        ),
        KasyDropDownItem(value: '/', label: tr.send_push_route_home),
        KasyDropDownItem(
          value: '/settings',
          label: tr.send_push_route_settings,
        ),
        if (withRevenuecat)
          KasyDropDownItem(
            value: '/premium',
            label: tr.send_push_route_premium,
          ),
        if (withLocalReminders)
          KasyDropDownItem(
            value: '/reminder',
            label: tr.send_push_route_reminder,
          ),
        if (withFeedback)
          KasyDropDownItem(
            value: '/feedback',
            label: tr.send_push_route_feedback,
          ),
      ],
    );

    final Widget formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormSection(label: tr.send_push_section_recipients, child: recipients),
        const SizedBox(height: KasySpacing.lg),
        _FormSection(label: tr.send_push_section_content, child: contentFields),
        const SizedBox(height: KasySpacing.lg),
        _FormSection(label: tr.send_push_section_advanced, child: advancedFields),
        // Send closes the form (route is optional), so the button flows right
        // after the last section and scrolls with the content — not pinned.
        const SizedBox(height: KasySpacing.lg),
        buildSubmit(expand: true),
      ],
    );

    final Widget previewPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // Same tight label-to-card gap as the Settings sections (`xs`), so the
          // label hugs its card instead of floating above it.
          padding: const EdgeInsets.only(
            left: KasySpacing.xs,
            bottom: KasySpacing.xs,
          ),
          child: Text(
            tr.send_push_preview_label.toUpperCase(),
            style: context.kasyTextTheme.sectionLabel.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        _NotificationPreview(
          appName: _appName,
          title: _titleCtrl.text,
          body: _bodyCtrl.text,
          imageUrl: _imageCtrl.text,
        ),
      ],
    );

    const double gutter = KasySpacing.pageHorizontalGutter;
    final double topInset = adminSectionTopInset(context);

    // Body-only: the admin shell supplies the chrome (web header on desktop,
    // titled app bar on tablet/phone). Wide viewports get two columns (form +
    // a fixed live preview); narrow stacks the preview on top. The send button
    // flows at the end of the form and scrolls with it (not pinned).
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 820;
        // Clear the home indicator / nav bar below the last control.
        final double bottomInset =
            MediaQuery.paddingOf(context).bottom + KasySpacing.xl;

        SingleChildScrollView scroll({
          required EdgeInsets padding,
          required Widget child,
          ScrollController? controller,
        }) => SingleChildScrollView(
          controller: controller,
          // Drag down to dismiss keyboard — the professional standard.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: child,
        );

        // Wide: only the form scrolls; the live preview stays FIXED beside it.
        // Narrow: the preview sits on top and the whole stack scrolls.
        final Widget bodyContent = wide
            ? Center(
                child: ConstrainedBox(
                  // Same content cap as every other admin section
                  // (Overview/Requests/Users/Kanban) — was a standalone 1100.
                  constraints: const BoxConstraints(
                    maxWidth: adminSectionMaxWidth,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: scroll(
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            topInset,
                            0,
                            bottomInset,
                          ),
                          child: formColumn,
                        ),
                      ),
                      const SizedBox(width: KasySpacing.xl),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          topInset,
                          gutter,
                          KasySpacing.xl,
                        ),
                        child: SizedBox(width: 340, child: previewPanel),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  // The form scrolls; the live preview stays PINNED at the top so
                  // the admin watches the notification update while filling the
                  // fields. An invisible copy of the preview at the head of the
                  // scroll reserves exactly its height, so the first section
                  // starts just below the banner and slides BEHIND it on scroll.
                  Positioned.fill(
                    child: scroll(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        topInset,
                        gutter,
                        bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Visibility(
                            visible: false,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: previewPanel,
                          ),
                          // Equals the banner's below-card height (breath +
                          // fade) AND the `lg` gap between sections, so the first
                          // section sits the same distance from the preview as
                          // every other section sits from the one above it.
                          const SizedBox(height: KasySpacing.lg),
                          formColumn,
                        ],
                      ),
                    ),
                  ),
                  // Sticky banner: an opaque page-colored band (so the scrolling
                  // form disappears behind it) with a fade at its bottom edge.
                  // It rides the scroll upward — its leading chrome gap collapses
                  // as everything moves together — then LOCKS at the top while the
                  // form keeps sliding under it. IgnorePointer lets drags over the
                  // preview still scroll the form (the preview has no interaction).
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        // The banner follows the scroll, then LOCKS — but stops a
                        // touch short of the top so a small breath of background
                        // stays above it, instead of slamming flush into the edge.
                        const double pinTopBreath = KasySpacing.sm;
                        final double travel = topInset - pinTopBreath;
                        final double offset = _scrollController.hasClients
                            ? _scrollController.offset
                            : 0;
                        final double shift = offset > travel ? travel : offset;
                        return Transform.translate(
                          offset: Offset(0, -shift),
                          child: child,
                        );
                      },
                      child: ValueListenableBuilder<bool>(
                        valueListenable: devInspectorActiveNotifier,
                        builder: (context, inspecting, child) {
                          // Sticky preview is non-interactive so drags scroll the
                          // form underneath — but while the DevInspector is
                          // active its subtree must stay hit-testable.
                          return IgnorePointer(
                            ignoring: !inspecting,
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: context.colors.background,
                              // Bottom breath under the preview card so the
                              // scrolling form clears it with air, instead of
                              // sliding behind right at its lower edge.
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                topInset,
                                gutter,
                                KasySpacing.sm,
                              ),
                              child: previewPanel,
                            ),
                            // Taller, eased fade so the form dissolves smoothly
                            // as it scrolls under the banner — a short linear
                            // band read as a dry, hard cut.
                            Container(
                              height: KasySpacing.md,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.45, 0.75, 1.0],
                                  colors: [
                                    context.colors.background,
                                    context.colors.background.withValues(
                                      alpha: 0.7,
                                    ),
                                    context.colors.background.withValues(
                                      alpha: 0.25,
                                    ),
                                    context.colors.background.withValues(
                                      alpha: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );

        return ScrollConfiguration(
          // Hide the scrollbar: on the two-column layout it lands between the
          // form and the live preview and reads as a stray mark next to the
          // cards. The form is short enough not to need it.
          behavior: const KasyKitScrollBehavior().copyWith(scrollbars: false),
          child: bodyContent,
        );
      },
    );
  }
}

/// A labelled card grouping form fields — the console's clean section look
/// (uppercase label + surface card with a hairline border and the component
/// shadow), so Send push reads as the same product as the rest of the admin.
class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // Matches the Settings sections: the label sits `xs` above its card,
          // hugging the container instead of floating with a wide gap.
          padding: const EdgeInsets.only(
            left: KasySpacing.xs,
            bottom: KasySpacing.xs,
          ),
          child: Text(
            label.toUpperCase(),
            style: context.kasyTextTheme.sectionLabel.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: KasyRadius.lgBorderRadius,
            border: Border.all(
              color: context.colors.outline.withValues(
                alpha: context.isDark ? 0.45 : 0.6,
              ),
            ),
            boxShadow: [KasyShadows.component(context)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(KasySpacing.md),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _EmailsSection extends StatelessWidget {
  final List<String> emails;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;
  final void Function(String) onRemove;
  final VoidCallback onChanged;
  final bool canAdd;
  final String label;
  final String hint;

  const _EmailsSection({
    required this.emails,
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
    required this.canAdd,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: KasyTextField(
                label: label,
                hint: hint,
                controller: controller,
                focusNode: focusNode,
                showRequiredIndicator: true,
                variant: KasyTextFieldVariant.secondary,
                contentType: KasyTextFieldContentType.email,
                onChanged: (_) => onChanged(),
                // "next" keeps keyboard open when pressing the action key.
                textInputAction: TextInputAction.next,
                onEditingComplete: onAdd,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: KasyButton.iconOnly(
                icon: KasyIcons.add,
                // Disabled (greyed, non-tappable) until the field holds a valid,
                // non-duplicate e-mail.
                onPressed: canAdd ? onAdd : null,
                size: KasyButtonSize.small,
                iconGlyphSize: 20,
              ),
            ),
          ],
        ),
        if (emails.isNotEmpty) ...[
          const SizedBox(height: KasySpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: emails
                .map(
                  (email) => _EmailChip(
                    email: email,
                    onRemove: () => onRemove(email),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _EmailChip extends StatelessWidget {
  final String email;
  final VoidCallback onRemove;

  const _EmailChip({required this.email, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // An e-mail is plain data the admin listed, not an action or a status — so
    // it reads as a neutral pill (clean, color used in moderation), not an
    // accent-blue tag. surfaceSecondary contrasts against the section card's
    // surface in both modes; the text uses the normal foreground tone.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: KasyRadius.fullBorderRadius,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            email,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              KasyIcons.close,
              size: KasyIconSize.xs,
              color: context.colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live notification preview — an iOS-style banner that mirrors what the push
// will look like, updating as the admin types. Cosmetic only (no logic).
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationPreview extends StatelessWidget {
  final String appName;
  final String title;
  final String body;
  final String imageUrl;

  const _NotificationPreview({
    required this.appName,
    required this.title,
    required this.body,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tr = t.settings.admin;
    final String name = appName.trim().isEmpty ? 'App' : appName.trim();
    final String url = imageUrl.trim();
    final bool showImage = url.startsWith('http');
    final bool titleEmpty = title.trim().isEmpty;
    final bool bodyEmpty = body.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        // Same shape, border and shadow as the form section cards
        // (`_FormSection`): the calm, near-flat component shadow has no downward
        // bias, so the card no longer casts a hard line into the fade below —
        // the whole screen reads as one organised, settings-like surface.
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: context.colors.outline.withValues(
            alpha: context.isDark ? 0.45 : 0.6,
          ),
        ),
        boxShadow: [KasyShadows.component(context)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppIconBadge(name: name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.muted,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.send_push_preview_now,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  titleEmpty ? tr.send_push_preview_title_placeholder : title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: titleEmpty
                        ? context.colors.muted
                        : context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bodyEmpty ? tr.send_push_preview_body_placeholder : body.trim(),
                  maxLines: kNotificationListBodyMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (showImage) ...[
            const SizedBox(width: 10),
            _PreviewThumb(url: url),
          ],
        ],
      ),
    );
  }
}

/// Rounded-square app icon (iOS app-icon look). Uses the REAL launcher icon
/// (`assets/branding/app-icon.png`) so the preview always mirrors the app's actual
/// logo — change the icon and this follows. Falls back to a tinted square with
/// the app's initial if the asset can't be loaded.
class _AppIconBadge extends StatelessWidget {
  final String name;
  const _AppIconBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: KasyRadius.mdBorderRadius,
      child: Image.asset(
        'assets/branding/app-icon.png',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final String letter =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: KasyRadius.mdBorderRadius,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Thumbnail of the notification image, loaded live from the URL. Keeps the old
/// frame while a new URL loads (gaplessPlayback) and shows a fallback on error.
class _PreviewThumb extends StatelessWidget {
  final String url;
  const _PreviewThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: KasyRadius.smBorderRadius,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _placeholder(context, loading: true),
          errorBuilder: (context, error, stack) =>
              _placeholder(context, loading: false),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, {required bool loading}) {
    return Container(
      color: context.colors.surfaceNeutralSoft,
      alignment: Alignment.center,
      child: Icon(
        loading ? KasyIcons.gallery : KasyIcons.imageOff,
        size: KasyIconSize.md,
        color: context.colors.muted,
      ),
    );
  }
}
