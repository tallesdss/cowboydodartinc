// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(globalSearchResults)
final globalSearchResultsProvider = GlobalSearchResultsFamily._();

final class GlobalSearchResultsProvider
    extends
        $FunctionalProvider<
          GlobalSearchResults,
          GlobalSearchResults,
          GlobalSearchResults
        >
    with $Provider<GlobalSearchResults> {
  GlobalSearchResultsProvider._({
    required GlobalSearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'globalSearchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$globalSearchResultsHash();

  @override
  String toString() {
    return r'globalSearchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GlobalSearchResults> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GlobalSearchResults create(Ref ref) {
    final argument = this.argument as String;
    return globalSearchResults(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalSearchResults value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalSearchResults>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalSearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$globalSearchResultsHash() =>
    r'08bdd58662c3af021041bc4ad243cc3e5577e65a';

final class GlobalSearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<GlobalSearchResults, String> {
  GlobalSearchResultsFamily._()
    : super(
        retry: null,
        name: r'globalSearchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GlobalSearchResultsProvider call(String query) =>
      GlobalSearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'globalSearchResultsProvider';
}
