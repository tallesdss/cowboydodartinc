// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoogleAdsNotifier)
final googleAdsProvider = GoogleAdsNotifierProvider._();

final class GoogleAdsNotifierProvider
    extends $NotifierProvider<GoogleAdsNotifier, AdState> {
  GoogleAdsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleAdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleAdsNotifierHash();

  @$internal
  @override
  GoogleAdsNotifier create() => GoogleAdsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdState>(value),
    );
  }
}

String _$googleAdsNotifierHash() => r'9def54e6e091ef2b8c2df143cbceea961a2c870b';

abstract class _$GoogleAdsNotifier extends $Notifier<AdState> {
  AdState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AdState, AdState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdState, AdState>,
              AdState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
