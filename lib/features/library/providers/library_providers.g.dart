// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveProfile)
final activeProfileProvider = ActiveProfileProvider._();

final class ActiveProfileProvider
    extends $NotifierProvider<ActiveProfile, String> {
  ActiveProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProfileHash();

  @$internal
  @override
  ActiveProfile create() => ActiveProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$activeProfileHash() => r'5e375c1971ee797d5e86c20fd01e73b7bfd7b525';

abstract class _$ActiveProfile extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends $NotifierProvider<Categories, List<LibraryCategory>> {
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  Categories create() => Categories();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LibraryCategory> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LibraryCategory>>(value),
    );
  }
}

String _$categoriesHash() => r'3e7e7d7ae8598357f7f3a6b968dbe28beba75960';

abstract class _$Categories extends $Notifier<List<LibraryCategory>> {
  List<LibraryCategory> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<LibraryCategory>, List<LibraryCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LibraryCategory>, List<LibraryCategory>>,
              List<LibraryCategory>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Pdfs)
final pdfsProvider = PdfsProvider._();

final class PdfsProvider extends $NotifierProvider<Pdfs, List<PdfDocument>> {
  PdfsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pdfsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pdfsHash();

  @$internal
  @override
  Pdfs create() => Pdfs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PdfDocument> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PdfDocument>>(value),
    );
  }
}

String _$pdfsHash() => r'ed2d2afd58c8416c2238ccf398ab471b4471cad7';

abstract class _$Pdfs extends $Notifier<List<PdfDocument>> {
  List<PdfDocument> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PdfDocument>, List<PdfDocument>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PdfDocument>, List<PdfDocument>>,
              List<PdfDocument>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Comments)
final commentsProvider = CommentsFamily._();

final class CommentsProvider
    extends $NotifierProvider<Comments, List<LibraryComment>> {
  CommentsProvider._({
    required CommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Comments create() => Comments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LibraryComment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LibraryComment>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'152419da9d3c4b6a8c8e71b34808e58b9504ba5a';

final class CommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Comments,
          List<LibraryComment>,
          List<LibraryComment>,
          List<LibraryComment>,
          String
        > {
  CommentsFamily._()
    : super(
        retry: null,
        name: r'commentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentsProvider call(String pdfId) =>
      CommentsProvider._(argument: pdfId, from: this);

  @override
  String toString() => r'commentsProvider';
}

abstract class _$Comments extends $Notifier<List<LibraryComment>> {
  late final _$args = ref.$arg as String;
  String get pdfId => _$args;

  List<LibraryComment> build(String pdfId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<LibraryComment>, List<LibraryComment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LibraryComment>, List<LibraryComment>>,
              List<LibraryComment>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Favorites)
final favoritesProvider = FavoritesProvider._();

final class FavoritesProvider
    extends $NotifierProvider<Favorites, List<String>> {
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  Favorites create() => Favorites();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$favoritesHash() => r'406fe99b27735ec453e4f2079b27d31f58837125';

abstract class _$Favorites extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
