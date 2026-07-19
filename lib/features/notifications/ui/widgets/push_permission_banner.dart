import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inline call-to-action that nudges the user to turn on push notifications.
///
/// Push is native-only: on web this renders nothing (permission_handler has no
/// web support and there is no native prompt). It also renders nothing once
/// permission is granted, so it self-hides the moment it's no longer needed.
///
/// States while not granted (native only):
///  - never asked / denied (Android can re-ask) → "Enable notifications",
///    which fires the native OS prompt directly (no custom pre-dialog: the OS
///    already shows its own localized prompt).
///  - permanently denied (iOS after a refusal) → "Open settings", since the OS
///    won't show the native prompt again and the only way back is the system
///    settings of the app.
///
/// When [autoRequest] is true, the first time it mounts in the "never asked"
/// state it fires the native prompt automatically — once per install, guarded
/// by a shared-preferences flag. Used on the notifications screen so simply
/// arriving there surfaces the native prompt.
class PushPermissionBanner extends ConsumerStatefulWidget {
  const PushPermissionBanner({super.key, this.autoRequest = false});

  /// Auto-fire the native prompt once when first shown in the "never asked"
  /// state. Leave false to require an explicit tap on the CTA.
  final bool autoRequest;

  @override
  ConsumerState<PushPermissionBanner> createState() =>
      _PushPermissionBannerState();
}

class _PushPermissionBannerState extends ConsumerState<PushPermissionBanner>
    with WidgetsBindingObserver {
  NotificationPermission? _permission;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from the OS settings: re-check so the banner self-hides if the
    // user just enabled notifications, or comes back if they disabled them —
    // without the user having to tap anything.
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      _reload();
    }
  }

  Future<void> _init() async {
    // Push is native-only — nothing to do (and nothing to render) on web.
    if (kIsWeb) return;
    final permission =
        await ref.read(notificationRepositoryProvider).getPermissionStatus();
    if (!mounted) return;

    // A fresh install reports "never asked" as `denied`, not `waiting`:
    // permission_handler maps iOS `notDetermined` to denied (Android behaves the
    // same before the first request). Gating the auto-prompt on `waiting` alone
    // meant it never fired — reinstalling never helped, since every new install
    // starts at `denied`. Treat both as askable: maybeAsk() shows the native
    // prompt when it was truly never asked, and is a harmless no-op once the OS
    // won't prompt again (already-denied on iOS). The once-per-install guard
    // below still keeps it to a single automatic attempt.
    final canAutoAsk = permission is NotificationPermissionWaiting ||
        permission is NotificationPermissionDenied;
    if (widget.autoRequest && canAutoAsk) {
      final prefs = ref.read(sharedPreferencesProvider);
      if (!prefs.getPushAutoRequested()) {
        await prefs.setPushAutoRequested(true);
        await permission.maybeAsk();
        await _reload();
        return;
      }
    }
    setState(() => _permission = permission);
  }

  Future<void> _reload() async {
    final permission =
        await ref.read(notificationRepositoryProvider).getPermissionStatus();
    if (mounted) setState(() => _permission = permission);
  }

  Future<void> _onPressed() async {
    if (_busy || _permission == null) return;
    setState(() => _busy = true);
    await _permission!.maybeAsk();
    await _reload();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    // Native-only, and only while permission is still missing.
    if (kIsWeb) return const SizedBox.shrink();
    final permission = _permission;
    if (permission == null || permission is NotificationPermissionGranted) {
      return const SizedBox.shrink();
    }

    final tr = context.t.notifications;
    final bool locked = permission is NotificationPermissionPermanentlyDenied;

    // Discreet single-row nudge: small muted bell + one line of copy + a compact
    // neutral button. Intentionally low-key so it doesn't compete with the list.
    return Padding(
      padding: const EdgeInsets.only(bottom: KasySpacing.smd),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          KasySpacing.md,
          KasySpacing.sm,
          KasySpacing.sm,
          KasySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: KasyRadius.lgBorderRadius,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              KasyIcons.notification,
              size: KasyIconSize.rowLeading,
              color: context.colors.muted,
            ),
            const SizedBox(width: KasySpacing.sm),
            Expanded(
              child: Text(
                locked ? tr.push_subtitle_disabled : tr.push_subtitle_waiting,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.75),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: KasySpacing.sm),
            KasyButton(
              label: locked ? tr.empty_cta_open_settings : tr.empty_cta,
              variant: KasyButtonVariant.outline,
              size: KasyButtonSize.small,
              isLoading: _busy,
              onPressed: _busy ? null : _onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
