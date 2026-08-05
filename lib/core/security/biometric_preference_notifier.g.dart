// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_preference_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiometricPreferenceNotifier)
final biometricPreferenceProvider = BiometricPreferenceNotifierProvider._();

final class BiometricPreferenceNotifierProvider
    extends $NotifierProvider<BiometricPreferenceNotifier, bool> {
  BiometricPreferenceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricPreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricPreferenceNotifierHash();

  @$internal
  @override
  BiometricPreferenceNotifier create() => BiometricPreferenceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricPreferenceNotifierHash() =>
    r'75e1397a0c9fdae91176f9c29122d8093f0e372c';

abstract class _$BiometricPreferenceNotifier extends $Notifier<bool> {
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
