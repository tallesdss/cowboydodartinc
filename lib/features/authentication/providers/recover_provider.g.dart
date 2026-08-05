// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recover_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecoverStateNotifier)
final recoverStateProvider = RecoverStateNotifierProvider._();

final class RecoverStateNotifierProvider
    extends $NotifierProvider<RecoverStateNotifier, RecoverState> {
  RecoverStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoverStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recoverStateNotifierHash();

  @$internal
  @override
  RecoverStateNotifier create() => RecoverStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecoverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecoverState>(value),
    );
  }
}

String _$recoverStateNotifierHash() =>
    r'8491e6adc32f0f1501219fb0be1c3c76c6194865';

abstract class _$RecoverStateNotifier extends $Notifier<RecoverState> {
  RecoverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RecoverState, RecoverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecoverState, RecoverState>,
              RecoverState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
