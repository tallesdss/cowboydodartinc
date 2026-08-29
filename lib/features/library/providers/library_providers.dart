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
  Stream<List<LibraryCategory>> build() {
    return ref.watch(libraryFirebaseRepositoryProvider).watchCategories();
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
    await ref.read(libraryFirebaseRepositoryProvider).addCategory(category);
  }

  Future<void> updateCategory(LibraryCategory category) async {
    await ref.read(libraryFirebaseRepositoryProvider).updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(libraryFirebaseRepositoryProvider).deleteCategory(id);
  }
}

// ----------------------------------------------------
// AUTHORS PROVIDER
// ----------------------------------------------------
@riverpod
class Authors extends _$Authors {
  @override
  Future<List<LibraryAuthor>> build() async {
    return ref.watch(libraryFirebaseRepositoryProvider).getAuthors();
  }

  Future<void> addAuthor({
    required String name,
    required String bio,
    required String createdBy,
  }) async {
    await ref.read(libraryFirebaseRepositoryProvider).addAuthor(
          name: name,
          bio: bio,
          createdBy: createdBy,
        );
    // Refresh the list after adding
    ref.invalidateSelf();
  }
}

// ----------------------------------------------------
// PDFS PROVIDER
// ----------------------------------------------------
@riverpod
class Pdfs extends _$Pdfs {
  late final LibraryFirebaseRepository _repository;

  @override
  Stream<List<PdfDocument>> build() {
    return ref.watch(libraryFirebaseRepositoryProvider).watchPdfs();
  }

  Future<void> addPdf({
    required String title,
    required String description,
    required List<String> categoryIds,
    required String author,
    String? authorId,
    required String fileUrl,
    required String thumbnailUrl,
    required List<String> tags,
    required String createdBy,
  }) async {
    await ref.read(libraryFirebaseRepositoryProvider).addPdf(
      title: title,
      description: description,
      categoryIds: categoryIds,
      author: author,
      authorId: authorId,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
      tags: tags,
      createdBy: createdBy,
    );
  }

  Future<void> deletePdf(String id) async {
    await ref.read(libraryFirebaseRepositoryProvider).deletePdf(id);
  }
}

// ----------------------------------------------------
// COMMENTS PROVIDER
// ----------------------------------------------------
@riverpod
class Comments extends _$Comments {
  late final LibraryFirebaseRepository _repository;

  @override
  Stream<List<LibraryComment>> build(String pdfId) {
    return ref.watch(libraryFirebaseRepositoryProvider).watchComments(pdfId);
  }

  Future<void> addComment({
    required String userId,
    required String userName,
    required String text,
    required int rating,
  }) async {
    final comment = LibraryComment(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      pdfId: pdfId,
      userId: userId,
      userName: userName,
      text: text,
      rating: rating,
      createdAt: DateTime.now(),
    );
    await ref.read(libraryFirebaseRepositoryProvider).addComment(comment);
  }
}

// ----------------------------------------------------
// FAVORITES PROVIDER
// ----------------------------------------------------
@riverpod
class Favorites extends _$Favorites {
  late final LibraryFirebaseRepository _repository;

  @override
  Stream<List<String>> build() {
    return ref.watch(libraryFirebaseRepositoryProvider).watchFavorites();
  }

  Future<void> toggleFavorite(String pdfId) async {
    await ref.read(libraryFirebaseRepositoryProvider).toggleFavorite(pdfId);
  }
}

