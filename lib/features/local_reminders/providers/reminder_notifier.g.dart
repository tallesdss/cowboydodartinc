// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReminderNotifier)
final reminderProvider = ReminderNotifierProvider._();

final class ReminderNotifierProvider
    extends $AsyncNotifierProvider<ReminderNotifier, ReminderState> {
  ReminderNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderNotifierHash();

  @$internal
  @override
  ReminderNotifier create() => ReminderNotifier();
}

String _$reminderNotifierHash() => r'7a855d8b15bc7efe46c98fb1d40f06403937d1bc';

abstract class _$ReminderNotifier extends $AsyncNotifier<ReminderState> {
  FutureOr<ReminderState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReminderState>, ReminderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReminderState>, ReminderState>,
              AsyncValue<ReminderState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
