// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptic_feedback_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HapticFeedbackNotifier)
final hapticFeedbackProvider = HapticFeedbackNotifierProvider._();

final class HapticFeedbackNotifierProvider
    extends $NotifierProvider<HapticFeedbackNotifier, bool> {
  HapticFeedbackNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticFeedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticFeedbackNotifierHash();

  @$internal
  @override
  HapticFeedbackNotifier create() => HapticFeedbackNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hapticFeedbackNotifierHash() =>
    r'e18e47b1cd32768b7b22f051a00d285c11a86bac';

abstract class _$HapticFeedbackNotifier extends $Notifier<bool> {
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
