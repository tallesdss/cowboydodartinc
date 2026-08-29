// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends $StreamNotifierProvider<Categories, List<LibraryCategory>> {
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
}

String _$categoriesHash() => r'21bc95d3ef322ad780daf52296b0d24096c1bff6';

abstract class _$Categories extends $StreamNotifier<List<LibraryCategory>> {
  Stream<List<LibraryCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<LibraryCategory>>, List<LibraryCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LibraryCategory>>,
                List<LibraryCategory>
              >,
              AsyncValue<List<LibraryCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Authors)
final authorsProvider = AuthorsProvider._();

final class AuthorsProvider
    extends $AsyncNotifierProvider<Authors, List<LibraryAuthor>> {
  AuthorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authorsHash();

  @$internal
  @override
  Authors create() => Authors();
}

String _$authorsHash() => r'72e02309005a51167d739f28db79d8f8fd0b18b1';

abstract class _$Authors extends $AsyncNotifier<List<LibraryAuthor>> {
  FutureOr<List<LibraryAuthor>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<LibraryAuthor>>, List<LibraryAuthor>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<LibraryAuthor>>, List<LibraryAuthor>>,
              AsyncValue<List<LibraryAuthor>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Pdfs)
final pdfsProvider = PdfsProvider._();

final class PdfsProvider
    extends $StreamNotifierProvider<Pdfs, List<PdfDocument>> {
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
}

String _$pdfsHash() => r'd5dc7138349ae334aa990e9b2cb5ef38d3bcef7c';

abstract class _$Pdfs extends $StreamNotifier<List<PdfDocument>> {
  Stream<List<PdfDocument>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PdfDocument>>, List<PdfDocument>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PdfDocument>>, List<PdfDocument>>,
              AsyncValue<List<PdfDocument>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Comments)
final commentsProvider = CommentsFamily._();

final class CommentsProvider
    extends $StreamNotifierProvider<Comments, List<LibraryComment>> {
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

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'3d0136849454d1992a6abc40c3fe92943eacfcef';

final class CommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Comments,
          AsyncValue<List<LibraryComment>>,
          List<LibraryComment>,
          Stream<List<LibraryComment>>,
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

abstract class _$Comments extends $StreamNotifier<List<LibraryComment>> {
  late final _$args = ref.$arg as String;
  String get pdfId => _$args;

  Stream<List<LibraryComment>> build(String pdfId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<LibraryComment>>, List<LibraryComment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LibraryComment>>,
                List<LibraryComment>
              >,
              AsyncValue<List<LibraryComment>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Favorites)
final favoritesProvider = FavoritesProvider._();

final class FavoritesProvider
    extends $StreamNotifierProvider<Favorites, List<String>> {
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
}

String _$favoritesHash() => r'2fedb5e10c45343db8b33808dc977046e5b249c7';

abstract class _$Favorites extends $StreamNotifier<List<String>> {
  Stream<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
