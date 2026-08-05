// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KanbanNotifier)
final kanbanProvider = KanbanNotifierProvider._();

final class KanbanNotifierProvider
    extends $AsyncNotifierProvider<KanbanNotifier, KanbanState> {
  KanbanNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kanbanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kanbanNotifierHash();

  @$internal
  @override
  KanbanNotifier create() => KanbanNotifier();
}

String _$kanbanNotifierHash() => r'56e3034182ea33e8e9faecb7ab05c67f1dca723f';

abstract class _$KanbanNotifier extends $AsyncNotifier<KanbanState> {
  FutureOr<KanbanState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<KanbanState>, KanbanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KanbanState>, KanbanState>,
              AsyncValue<KanbanState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
