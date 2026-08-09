import 'package:cowboydodartinc/features/library/repositories/library_mock_storage.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_providers.g.dart';

// ----------------------------------------------------
// ACTIVE PROFILE PROVIDER
// ----------------------------------------------------
@riverpod
class ActiveProfile extends _$ActiveProfile {
  late final LibraryMockStorage _storage;

  @override
  String build() {
    _storage = ref.watch(libraryMockStorageProvider);
    return _storage.getActiveProfile();
  }

  void setProfile(String profile) {
    _storage.saveActiveProfile(profile);
    state = profile;
  }

  bool get isAdmin => state == 'admin';
}

// ----------------------------------------------------
// CATEGORIES PROVIDER
// ----------------------------------------------------
@riverpod
class Categories extends _$Categories {
  late final LibraryMockStorage _storage;

  @override
  List<LibraryCategory> build() {
    _storage = ref.watch(libraryMockStorageProvider);
    return _storage.getCategories();
  }

  void refresh() {
    state = _storage.getCategories();
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
    await _storage.addCategory(category);
    refresh();
  }

  Future<void> updateCategory(LibraryCategory category) async {
    await _storage.updateCategory(category);
    refresh();
  }

  Future<void> deleteCategory(String id) async {
    await _storage.deleteCategory(id);
    refresh();
  }
}

// ----------------------------------------------------
// PDFS PROVIDER
// ----------------------------------------------------
@riverpod
class Pdfs extends _$Pdfs {
  late final LibraryMockStorage _storage;

  @override
  List<PdfDocument> build() {
    _storage = ref.watch(libraryMockStorageProvider);
    return _storage.getPdfs();
  }

  void refresh() {
    state = _storage.getPdfs();
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
    final pdf = PdfDocument(
      id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      categoryIds: categoryIds,
      author: author,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
      tags: tags,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await _storage.addPdf(pdf);
    refresh();
  }

  Future<void> deletePdf(String id) async {
    await _storage.deletePdf(id);
    refresh();
  }
}

// ----------------------------------------------------
// COMMENTS PROVIDER
// ----------------------------------------------------
@riverpod
class Comments extends _$Comments {
  late final LibraryMockStorage _storage;

  @override
  List<LibraryComment> build(String pdfId) {
    _storage = ref.watch(libraryMockStorageProvider);
    return _storage.getComments(pdfId);
  }

  void refresh() {
    state = _storage.getComments(pdfId);
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
    await _storage.addComment(comment);
    refresh();
  }
}

// ----------------------------------------------------
// FAVORITES PROVIDER
// ----------------------------------------------------
@riverpod
class Favorites extends _$Favorites {
  late final LibraryMockStorage _storage;

  @override
  List<String> build() {
    _storage = ref.watch(libraryMockStorageProvider);
    return _storage.getFavorites();
  }

  void refresh() {
    state = _storage.getFavorites();
  }

  Future<void> toggleFavorite(String pdfId) async {
    await _storage.toggleFavorite(pdfId);
    refresh();
  }
}
