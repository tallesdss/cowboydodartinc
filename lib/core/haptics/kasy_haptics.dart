import 'package:cowboydodartinc/core/haptics/haptic_feedback_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KasyHaptics {
  KasyHaptics._();

  static bool _isEnabled(BuildContext context) =>
      ProviderScope.containerOf(context).read(hapticFeedbackProvider);

  static Future<void> light(BuildContext context) async {
    if (_isEnabled(context)) await HapticFeedback.lightImpact();
  }

  static Future<void> medium(BuildContext context) async {
    if (_isEnabled(context)) await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy(BuildContext context) async {
    if (_isEnabled(context)) await HapticFeedback.heavyImpact();
  }

  static Future<void> selection(BuildContext context) async {
    if (_isEnabled(context)) await HapticFeedback.selectionClick();
  }
}
