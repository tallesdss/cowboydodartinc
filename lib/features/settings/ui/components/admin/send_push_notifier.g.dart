// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_push_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SendPushNotifier)
final sendPushProvider = SendPushNotifierProvider._();

final class SendPushNotifierProvider
    extends $NotifierProvider<SendPushNotifier, AsyncValue<void>> {
  SendPushNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendPushProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendPushNotifierHash();

  @$internal
  @override
  SendPushNotifier create() => SendPushNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$sendPushNotifierHash() => r'bd0ab4a11a60c15af9e0de16cd84e9ef775b814d';

abstract class _$SendPushNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
