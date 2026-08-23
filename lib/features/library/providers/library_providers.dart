import 'package:cowboydodartinc/features/library/repositories/library_firebase_repository.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_providers.g.dart';


// ----------------------------------------------------
// CATEGORIES PROVIDER
// ----------------------------------------------------
@riverpod
class Categories extends _$Categories {
  late final LibraryFirebaseRepository _repository;

  @override
  List<LibraryCategory> build() {
    _repository = ref.watch(libraryFirebaseRepositoryProvider);
    _fetchCategories();
    return [];
  }

  Future<void> _fetchCategories() async {
    try {
      final list = await _repository.getCategories();
      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _fetchCategories();
  }

  Future<void> addCategory({
    required String name,
    required String description,
    required String icon,
    required String color,
  }) async {
    final category = LibraryCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
    );
    await _repository.addCategory(category);
    await refresh();
  }

  Future<void> updateCategory(LibraryCategory category) async {
    await _repository.updateCategory(category);
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await refresh();
  }
}

// ----------------------------------------------------
// PDFS PROVIDER
// ----------------------------------------------------
@riverpod
class Pdfs extends _$Pdfs {
  late final LibraryFirebaseRepository _repository;

  @override
  List<PdfDocument> build() {
    _repository = ref.watch(libraryFirebaseRepositoryProvider);
    _fetchPdfs();
    return [];
  }

  Future<void> _fetchPdfs() async {
    try {
      final list = await _repository.getPdfs();
      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _fetchPdfs();
  }

  Future<void> addPdf({
    required String title,
    required String description,
    required List<String> categoryIds,
    required String author,
    required String fileUrl,
    required String thumbnailUrl,
    required List<String> tags,
    required String createdBy,
  }) async {
    await _repository.addPdf(
      title: title,
      description: description,
      categoryIds: categoryIds,
      author: author,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
      tags: tags,
      createdBy: createdBy,
    );
    await refresh();
  }

  Future<void> deletePdf(String id) async {
    await _repository.deletePdf(id);
    await refresh();
  }
}

// ----------------------------------------------------
// COMMENTS PROVIDER
// ----------------------------------------------------
@riverpod
class Comments extends _$Comments {
  late final LibraryFirebaseRepository _repository;

  @override
  List<LibraryComment> build(String pdfId) {
    _repository = ref.watch(libraryFirebaseRepositoryProvider);
    _fetchComments();
    return [];
  }

  Future<void> _fetchComments() async {
    try {
      final list = await _repository.getComments(pdfId);
      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _fetchComments();
  }

  Future<void> addComment({
    required String userName,
    required String text,
    required int rating,
  }) async {
    final comment = LibraryComment(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      pdfId: pdfId,
      userName: userName,
      text: text,
      rating: rating,
      createdAt: DateTime.now(),
    );
    await _repository.addComment(comment);
    await refresh();
  }
}

// ----------------------------------------------------
// FAVORITES PROVIDER
// ----------------------------------------------------
@riverpod
class Favorites extends _$Favorites {
  late final LibraryFirebaseRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(libraryFirebaseRepositoryProvider);
    _fetchFavorites();
    return [];
  }

  Future<void> _fetchFavorites() async {
    try {
      final list = await _repository.getFavorites();
      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _fetchFavorites();
  }

  Future<void> toggleFavorite(String pdfId) async {
    await _repository.toggleFavorite(pdfId);
    await refresh();
  }
}

