import 'package:cowboydodartinc/core/security/biometric_copy_slot.dart';
import 'package:cowboydodartinc/core/security/biometric_service.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolved copy on this device (`getAvailableBiometrics`), per language bundle.
final biometricCopySlotFamily =
    FutureProvider.family<BiometricCopySlot, TargetPlatform>(
  (ref, platform) =>
      ref.read(biometricServiceProvider).resolveCopySlot(platform),
);

/// UI strings tuned to [BiometricCopySlot] plus [biometric_prompt] variants.
final class BioBundle {
  BioBundle({
    required this.settingsSubtitle,
    required this.loginReason,
    required this.enableReason,
    required this.unavailableMessage,
    required this.promptTitle,
    required this.promptMessage,
    required this.notNowLabel,
    required this.enableLabel,
  });

  final String settingsSubtitle;
  final String loginReason;
  final String enableReason;
  final String unavailableMessage;
  final String promptTitle;
  final String promptMessage;
  final String notNowLabel;
  final String enableLabel;

  factory BioBundle.fromSlot(BuildContext context, BiometricCopySlot slot) {
    final s = context.t.settings;
    final bp = context.t.biometric_prompt;

    switch (slot) {
      case BiometricCopySlot.iosFaceOnly:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_ios_face,
          loginReason: s.biometric_login_reason_ios_face,
          enableReason: s.biometric_enable_reason_ios_face,
          unavailableMessage: s.biometric_unavailable_message_ios_face,
          promptTitle: bp.title_ios_face,
          promptMessage: bp.message_ios_face,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.iosFingerprintOnly:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_ios_touch,
          loginReason: s.biometric_login_reason_ios_touch,
          enableReason: s.biometric_enable_reason_ios_touch,
          unavailableMessage: s.biometric_unavailable_message_ios_touch,
          promptTitle: bp.title_ios_touch,
          promptMessage: bp.message_ios_touch,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.iosFaceAndFingerprint:
      case BiometricCopySlot.iosUndetermined:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_ios,
          loginReason: s.biometric_login_reason_ios,
          enableReason: s.biometric_enable_reason_ios,
          unavailableMessage: s.biometric_unavailable_message_ios,
          promptTitle: bp.title_ios_mixed,
          promptMessage: bp.message_ios_mixed,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.androidFaceOnly:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_android_face,
          loginReason: s.biometric_login_reason_android_face,
          enableReason: s.biometric_enable_reason_android_face,
          unavailableMessage: s.biometric_unavailable_message_android_face,
          promptTitle: bp.title_android_face,
          promptMessage: bp.message_android_face,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.androidFingerprintOnly:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_android_fingerprint,
          loginReason: s.biometric_login_reason_android_fingerprint,
          enableReason: s.biometric_enable_reason_android_fingerprint,
          unavailableMessage: s.biometric_unavailable_message_android_fingerprint,
          promptTitle: bp.title_android_fingerprint,
          promptMessage: bp.message_android_fingerprint,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.androidFaceAndFingerprint:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_android_face_and_fingerprint,
          loginReason: s.biometric_login_reason_android_face_and_fingerprint,
          enableReason: s.biometric_enable_reason_android_face_and_fingerprint,
          unavailableMessage:
              s.biometric_unavailable_message_android_face_and_fingerprint,
          promptTitle: bp.title_android_face_and_fingerprint,
          promptMessage: bp.message_android_face_and_fingerprint,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
      case BiometricCopySlot.androidUndetermined:
      case BiometricCopySlot.unsupported:
        return BioBundle(
          settingsSubtitle: s.biometric_subtitle_android,
          loginReason: s.biometric_login_reason_android,
          enableReason: s.biometric_enable_reason_android,
          unavailableMessage: s.biometric_unavailable_message_android,
          promptTitle: bp.title_android_mixed,
          promptMessage: bp.message_android_mixed,
          notNowLabel: bp.not_now,
          enableLabel: bp.enable,
        );
    }
  }

  /// Broad copy while biometric types are still loading (safe default).
  factory BioBundle.fallbackForPlatform(BuildContext context) {
    final isApple =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return BioBundle.fromSlot(
      context,
      isApple
          ? BiometricCopySlot.iosUndetermined
          : BiometricCopySlot.androidUndetermined,
    );
  }
}
