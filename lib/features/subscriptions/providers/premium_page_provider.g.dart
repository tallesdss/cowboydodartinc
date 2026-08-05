// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PremiumStateNotifier)
final premiumStateProvider = PremiumStateNotifierFamily._();

final class PremiumStateNotifierProvider
    extends $AsyncNotifierProvider<PremiumStateNotifier, PremiumState> {
  PremiumStateNotifierProvider._({
    required PremiumStateNotifierFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'premiumStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$premiumStateNotifierHash();

  @override
  String toString() {
    return r'premiumStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PremiumStateNotifier create() => PremiumStateNotifier();

  @override
  bool operator ==(Object other) {
    return other is PremiumStateNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$premiumStateNotifierHash() =>
    r'2f8444a0b886c01a427ee3451ac09c50cac77cad';

final class PremiumStateNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PremiumStateNotifier,
          AsyncValue<PremiumState>,
          PremiumState,
          FutureOr<PremiumState>,
          bool
        > {
  PremiumStateNotifierFamily._()
    : super(
        retry: null,
        name: r'premiumStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PremiumStateNotifierProvider call({bool preview = false}) =>
      PremiumStateNotifierProvider._(argument: preview, from: this);

  @override
  String toString() => r'premiumStateProvider';
}

abstract class _$PremiumStateNotifier extends $AsyncNotifier<PremiumState> {
  late final _$args = ref.$arg as bool;
  bool get preview => _$args;

  FutureOr<PremiumState> build({bool preview = false});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PremiumState>, PremiumState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PremiumState>, PremiumState>,
              AsyncValue<PremiumState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(preview: _$args));
  }
}
