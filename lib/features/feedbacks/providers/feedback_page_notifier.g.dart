// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_page_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedbackPageNotifier)
final feedbackPageProvider = FeedbackPageNotifierProvider._();

final class FeedbackPageNotifierProvider
    extends $AsyncNotifierProvider<FeedbackPageNotifier, FeedbackPageState> {
  FeedbackPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackPageNotifierHash();

  @$internal
  @override
  FeedbackPageNotifier create() => FeedbackPageNotifier();
}

String _$feedbackPageNotifierHash() =>
    r'7830f7638b346dee86c5edb4c81da5b797bc7bf5';

abstract class _$FeedbackPageNotifier
    extends $AsyncNotifier<FeedbackPageState> {
  FutureOr<FeedbackPageState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FeedbackPageState>, FeedbackPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedbackPageState>, FeedbackPageState>,
              AsyncValue<FeedbackPageState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
