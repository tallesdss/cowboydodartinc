// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether biometric was verified in the current session.

@ProviderFor(BiometricSessionNotifier)
final biometricSessionProvider = BiometricSessionNotifierProvider._();

/// Tracks whether biometric was verified in the current session.
final class BiometricSessionNotifierProvider
    extends $NotifierProvider<BiometricSessionNotifier, bool> {
  /// Tracks whether biometric was verified in the current session.
  BiometricSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricSessionNotifierHash();

  @$internal
  @override
  BiometricSessionNotifier create() => BiometricSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricSessionNotifierHash() =>
    r'7db8541b1b78363b096020eb1c61ac62ee3145d8';

/// Tracks whether biometric was verified in the current session.

abstract class _$BiometricSessionNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
