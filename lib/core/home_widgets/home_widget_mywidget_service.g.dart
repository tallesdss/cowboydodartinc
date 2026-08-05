// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget_mywidget_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyWidgetHomeWidget)
final myWidgetHomeWidgetProvider = MyWidgetHomeWidgetProvider._();

final class MyWidgetHomeWidgetProvider
    extends $NotifierProvider<MyWidgetHomeWidget, void> {
  MyWidgetHomeWidgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myWidgetHomeWidgetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWidgetHomeWidgetHash();

  @$internal
  @override
  MyWidgetHomeWidget create() => MyWidgetHomeWidget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$myWidgetHomeWidgetHash() =>
    r'6888b1a7c857ac355dbc5f760b896131c2ee9db8';

abstract class _$MyWidgetHomeWidget extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
