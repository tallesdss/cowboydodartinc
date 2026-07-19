import 'dart:async';

import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_phone_frame.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_push_notification_banner.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Decorative push-notification stack for the notifications onboarding step:
/// three iOS-style banners drop in one after another (with haptics) over a
/// faded phone frame — every card uses [OnboardingPushNotificationBanner].
class OnboardingNotificationToastShowcase extends StatefulWidget {
  const OnboardingNotificationToastShowcase({super.key});

  static const int _toastCount = 3;
  static const int _maxVisible = 3;
  static const double _peekOffset = 7;
  /// Extra width on each side of the phone (toast extends past the frame).
  static const double _toastSideOverflow = 40;
  static const Duration _initialDelay = Duration(milliseconds: 350);
  static const Duration _interval = Duration(milliseconds: 680);

  @override
  State<OnboardingNotificationToastShowcase> createState() =>
      _OnboardingNotificationToastShowcaseState();
}

class _ShowcaseToastItem {
  _ShowcaseToastItem({
    required this.controller,
    required this.heavyHaptic,
    required this.appName,
    required this.headline,
    required this.body,
    required this.sentAt,
  });

  final AnimationController controller;
  final bool heavyHaptic;
  final String appName;
  final String headline;
  final String body;
  final String sentAt;
}

class _ShowcaseToastSpec {
  const _ShowcaseToastSpec({
    required this.heavyHaptic,
    required this.appName,
    required this.headline,
    required this.body,
    required this.sentAt,
  });

  final bool heavyHaptic;
  final String appName;
  final String headline;
  final String body;
  final String sentAt;
}

class _OnboardingNotificationToastShowcaseState
    extends State<OnboardingNotificationToastShowcase>
    with TickerProviderStateMixin {
  final List<_ShowcaseToastItem> _items = [];

  Timer? _timer;
  int _nextIndex = 0;
  List<_ShowcaseToastSpec>? _script;

  @override
  void initState() {
    super.initState();
    _timer = Timer(OnboardingNotificationToastShowcase._initialDelay, _tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_script != null) return;
    final toasts = Translations.of(context).onboarding.notifications.toasts;
    final String appName = toasts.push_app_name;
    final String sentAt = toasts.push_sent_at;
    _script = [
      _pushEntry(
        appName: appName,
        sentAt: sentAt,
        headline: toasts.push_headline,
        body: toasts.push_body,
        heavyHaptic: true,
      ),
      _pushEntry(
        appName: appName,
        sentAt: sentAt,
        headline: toasts.subscriber_title,
        body: toasts.subscriber_message,
      ),
      _pushEntry(
        appName: appName,
        sentAt: sentAt,
        headline: toasts.streak_title,
        body: toasts.streak_message,
      ),
    ];
  }

  _ShowcaseToastSpec _pushEntry({
    required String appName,
    required String sentAt,
    required String headline,
    required String body,
    bool heavyHaptic = false,
  }) =>
      _ShowcaseToastSpec(
        heavyHaptic: heavyHaptic,
        appName: appName,
        headline: headline,
        body: body,
        sentAt: sentAt,
      );

  void _tick() {
    if (!mounted || _script == null) return;
    if (_nextIndex >= OnboardingNotificationToastShowcase._toastCount) {
      _timer?.cancel();
      return;
    }

    final spec = _script![_nextIndex++];
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 260),
    );
    final item = _ShowcaseToastItem(
      controller: controller,
      heavyHaptic: spec.heavyHaptic,
      appName: spec.appName,
      headline: spec.headline,
      body: spec.body,
      sentAt: spec.sentAt,
    );

    if (item.heavyHaptic) {
      unawaited(KasyHaptics.medium(context));
    } else {
      unawaited(KasyHaptics.light(context));
    }

    setState(() {
      if (_items.length >= OnboardingNotificationToastShowcase._maxVisible) {
        _dismiss(_items.last);
      }
      _items.insert(0, item);
    });
    item.controller.forward();

    _timer = Timer(OnboardingNotificationToastShowcase._interval, _tick);
  }

  void _dismiss(_ShowcaseToastItem item) {
    if (!_items.contains(item)) return;
    item.controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _items.remove(item);
      });
      item.controller.dispose();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Widget _buildToastStack() {
    if (_items.isEmpty) return const SizedBox.shrink();

    final visible =
        _items.take(OnboardingNotificationToastShowcase._maxVisible).toList();

    if (visible.length == 1) {
      return _AnimatedShowcaseToast(
        key: ValueKey(visible.first),
        item: visible.first,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: visible.reversed.map((item) {
        final fromFront = visible.indexOf(item);
        final yOffset =
            fromFront * OnboardingNotificationToastShowcase._peekOffset;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: (1.0 - fromFront * 0.04).clamp(0.0, 1.0),
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: (1.0 - fromFront * 0.12).clamp(0.0, 1.0),
              child: _AnimatedShowcaseToast(
                key: ValueKey(item),
                item: item,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Fill the entire hero slot — no min clamp (was forcing 360px and
          // clipping on typical phone viewports).
          final double phoneHeight = constraints.maxHeight;
          final double phoneWidth =
              (phoneHeight * 0.48).clamp(188.0, 248.0);
          final double toastWidth =
              phoneWidth + OnboardingNotificationToastShowcase._toastSideOverflow * 2;

          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: toastWidth,
              height: phoneHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: OnboardingPhoneFrame(
                      width: phoneWidth,
                      height: phoneHeight,
                    ),
                  ),
                  Positioned(
                    left: (toastWidth - phoneWidth) / 2,
                    width: phoneWidth,
                    bottom: 0,
                    height: phoneHeight * 0.52,
                    child: const OnboardingPhoneBottomBleed(),
                  ),
                  Positioned(
                    top: phoneHeight * 0.17,
                    left: 0,
                    right: 0,
                    child: _buildToastStack(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedShowcaseToast extends StatelessWidget {
  const _AnimatedShowcaseToast({super.key, required this.item});

  final _ShowcaseToastItem item;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: item.controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    final fade = CurvedAnimation(
      parent: item.controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      reverseCurve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: OnboardingPushNotificationBanner(
          appName: item.appName,
          headline: item.headline,
          body: item.body,
          sentAt: item.sentAt,
          compact: true,
        ),
      ),
    );
  }
}
