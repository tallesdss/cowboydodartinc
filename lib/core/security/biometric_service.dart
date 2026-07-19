import 'package:cowboydodartinc/core/security/biometric_copy_slot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider = Provider<BiometricService>(
  (_) => BiometricService(),
);

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Maps enrolled biometrics ([getAvailableBiometrics]) to UX copy buckets.
  Future<BiometricCopySlot> resolveCopySlot(TargetPlatform platform) async {
    if (kIsWeb) return BiometricCopySlot.unsupported;
    try {
      if (!(await _auth.isDeviceSupported() && await _auth.canCheckBiometrics)) {
        return BiometricCopySlot.unsupported;
      }
      final types = await _auth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face);
      final hasFinger = types.contains(BiometricType.fingerprint);
      final hasIris = types.contains(BiometricType.iris);
      final vague = types.any(
        (t) => t == BiometricType.weak || t == BiometricType.strong,
      );

      if (platform == TargetPlatform.iOS ||
          platform == TargetPlatform.macOS) {
        if (hasFace && hasFinger) {
          return BiometricCopySlot.iosFaceAndFingerprint;
        }
        if (hasFace) return BiometricCopySlot.iosFaceOnly;
        if (hasFinger || hasIris) return BiometricCopySlot.iosFingerprintOnly;
        if (types.isEmpty && vague) return BiometricCopySlot.iosUndetermined;
        return BiometricCopySlot.iosUndetermined;
      }

      if (hasFace && hasFinger) {
        return BiometricCopySlot.androidFaceAndFingerprint;
      }
      if (hasFace) return BiometricCopySlot.androidFaceOnly;
      if (hasFinger || hasIris) {
        return BiometricCopySlot.androidFingerprintOnly;
      }
      if (vague) return BiometricCopySlot.androidUndetermined;
      return BiometricCopySlot.androidUndetermined;
    } catch (_) {
      return BiometricCopySlot.unsupported;
    }
  }

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
