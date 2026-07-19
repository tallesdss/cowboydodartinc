import 'package:cowboydodartinc/components/kasy_toast.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that exposes toast helpers callable from providers (no BuildContext).
/// Prefers [showKasyToast] when a context is available.
class ToastBuilder {
  void success({
    required String title,
    required String text,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    showKasyToast(ctx,
        title: title,
        message: text,
        tone: KasyToastTone.success,
        duration: duration);
  }

  void error({
    required String title,
    required String text,
    Duration duration = const Duration(seconds: 3),
    String? reason,
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    showKasyToast(
      ctx,
      title: title,
      message: reason != null ? '$text ($reason)' : text,
      tone: KasyToastTone.danger,
      duration: duration,
    );
  }

  void alert({
    required String title,
    required String text,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    showKasyToast(ctx,
        title: title,
        message: text,
        tone: KasyToastTone.warning,
        duration: duration);
  }
}

// ignore: avoid_classes_with_only_static_members
final toastProvider = Provider<ToastBuilder>((ref) => ToastBuilder());
