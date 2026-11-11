import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryFirebaseRepositoryProvider = Provider<LibraryFirebaseRepository>((ref) {
  return LibraryFirebaseRepository();
});

class LibraryFirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentDisplayName => _auth.currentUser?.displayName ?? '';

  // ----------------------------------------------------
  // PROFILE SELECTION (Admin vs Cliente)
  // ----------------------------------------------------
  Future<String> getActiveProfile() async {
    if (currentUserId.isEmpty) return 'cliente';
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    if (doc.exists) {
      return (doc.data()?['role'] as String?) ?? 'cliente';
    }
    return 'cliente';
  }

  // ----------------------------------------------------
  // CATEGORIES
  // ----------------------------------------------------
  Future<List<LibraryCategory>> getCategories() async {
    final snapshot = await _firestore.collection('categories').orderBy('criado_em').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final rawDate = data['criado_em'];
      return LibraryCategory(
        id: doc.id,
        name: data['nome'] as String? ?? '',
        description: data['descricao'] as String? ?? '',
        icon: data['icone'] as String? ?? '',
        color: data['icone_cor'] as String? ?? '',
        createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      );
    }).toList();
  }

  Stream<List<LibraryCategory>> watchCategories() {
    return _firestore.collection('categories').orderBy('criado_em').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawDate = data['criado_em'];
        return LibraryCategory(
          id: doc.id,
          name: data['nome'] as String? ?? '',
          description: data['descricao'] as String? ?? '',
          icon: data['icone'] as String? ?? '',
          color: data['icone_cor'] as String? ?? '',
          createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> addCategory(LibraryCategory category) async {
    await _firestore.collection('categories').doc(category.id).set({
      'nome': category.name,
      'descricao': category.description,
      'icone': category.icon,
      'icone_cor': category.color,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(LibraryCategory category) async {
    await _firestore.collection('categories').doc(category.id).update({
      'nome': category.name,
      'descricao': category.description,
      'icone': category.icon,
      'icone_cor': category.color,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  // ----------------------------------------------------
  // AUTHORS
  // ----------------------------------------------------
  Future<List<LibraryAuthor>> getAuthors() async {
    final snapshot = await _firestore
        .collection('autores')
        .orderBy('name', descending: false)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      return LibraryAuthor.fromMap(data);
    }).toList();
  }

  Future<void> addAuthor({
    required String name,
    required String bio,
    required String createdBy,
  }) async {
    await _firestore.collection('autores').add({
      'name': name,
      'bio': bio,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------------------------
  // PDFS
  // ----------------------------------------------------
  Future<List<PdfDocument>> getPdfs() async {
    final publicQuery = await _firestore
        .collection('pdfs')
        .where('is_public', isEqualTo: true)
        .orderBy('criado_em', descending: true)
        .get();
    final privateQuery = currentUserId.isEmpty
        ? null
        : await _firestore
            .collection('pdfs')
            .where('autor_id', isEqualTo: currentUserId)
            .orderBy('criado_em', descending: true)
            .get();
    final documents = <String, PdfDocument>{
      for (final doc in publicQuery.docs) doc.id: _pdfFromDocument(doc),
      if (privateQuery != null)
        for (final doc in privateQuery.docs) doc.id: _pdfFromDocument(doc),
    };
    return documents.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Stream<List<PdfDocument>> watchPdfs() {
    final controller = StreamController<List<PdfDocument>>();
    final publicPdfs = <String, PdfDocument>{};
    final ownedPdfs = <String, PdfDocument>{};

    void emitPdfs() {
      final merged = {...publicPdfs, ...ownedPdfs}.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(merged);
    }

    final publicSubscription = _firestore
        .collection('pdfs')
        .where('is_public', isEqualTo: true)
        .orderBy('criado_em', descending: true)
        .snapshots()
        .listen((snapshot) {
          publicPdfs
            ..clear()
            ..addEntries(snapshot.docs.map((doc) => MapEntry(doc.id, _pdfFromDocument(doc))));
          emitPdfs();
        }, onError: controller.addError);

    final Stream<QuerySnapshot<Map<String, dynamic>>> ownedStream = currentUserId.isEmpty
        ? const Stream.empty()
        : _firestore
            .collection('pdfs')
            .where('autor_id', isEqualTo: currentUserId)
            .orderBy('criado_em', descending: true)
            .snapshots();
    final ownedSubscription = ownedStream.listen((snapshot) {
      ownedPdfs
        ..clear()
        ..addEntries(snapshot.docs.map((doc) => MapEntry(doc.id, _pdfFromDocument(doc))));
      emitPdfs();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await publicSubscription.cancel();
      await ownedSubscription.cancel();
    };
    return controller.stream;
  }

  PdfDocument _pdfFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawDate = data['criado_em'];
    return PdfDocument(
      id: doc.id,
      title: data['titulo'] as String? ?? '',
      description: data['descricao'] as String? ?? '',
      categoryIds: List<String>.from(data['categoryIds'] as Iterable? ?? []),
      author: data['autor_nome'] as String? ?? 'Desconhecido',
      authorId: data['escritor_id'] as String?,
      fileUrl: data['arquivo_url'] as String? ?? '',
      storagePath: data['storage_path'] as String? ?? '',
      thumbnailUrl: data['thumbnail_url'] as String? ?? '',
      tags: List<String>.from(data['tags'] as Iterable? ?? []),
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      createdBy: data['autor_id'] as String? ?? '',
      isPublic: data['is_public'] as bool? ?? true,
      views: data['views'] as int? ?? 0,
      downloads: data['downloads'] as int? ?? 0,
    );
  }

  String newPdfId() => _firestore.collection('pdfs').doc().id;

  Future<void> addPdf({
    required String id,
    required String title,
    required String description,
    required List<String> categoryIds,
    required String author,
    String? authorId,
    required String storagePath,
    required bool isPublic,
    required String thumbnailUrl,
    required List<String> tags,
    required String createdBy,
  }) async {
    await _firestore.collection('pdfs').doc(id).set({
      'titulo': title,
      'descricao': description,
      'categoryIds': categoryIds,
      'autor_nome': author,
      if (authorId != null) 'escritor_id': authorId,
      'storage_path': storagePath,
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'autor_id': createdBy,
      'is_public': isPublic,
      'views': 0,
      'downloads': 0,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePdf(String id) async {
    final document = _firestore.collection('pdfs').doc(id);
    final snapshot = await document.get();
    final storagePath = snapshot.data()?['storage_path'] as String?;
    if (storagePath != null && storagePath.isNotEmpty) {
      await _storage.ref(storagePath).delete();
    }
    await document.delete();
  }

  // ----------------------------------------------------
  // COMMENTS
  // ----------------------------------------------------
  Future<List<LibraryComment>> getComments(String pdfId) async {
    final snapshot = await _firestore.collection('comments')
        .where('pdf_id', isEqualTo: pdfId)
        .orderBy('criado_em', descending: true)
        .get();
        
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final rawDate = data['criado_em'];
      return LibraryComment(
        id: doc.id,
        pdfId: data['pdf_id'] as String? ?? '',
        userId: data['usuario_id'] as String? ?? '',
        userName: data['usuario_nome'] as String? ?? 'Anônimo',
        text: data['comentario'] as String? ?? '',
        rating: data['nota'] as int? ?? data['avaliacao'] as int? ?? 5,
        createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      );
    }).toList();
  }

  Stream<List<LibraryComment>> watchComments(String pdfId) {
    return _firestore.collection('comments')
        .where('pdf_id', isEqualTo: pdfId)
        .orderBy('criado_em', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawDate = data['criado_em'];
        return LibraryComment(
          id: doc.id,
          pdfId: data['pdf_id'] as String? ?? '',
          userId: data['usuario_id'] as String? ?? '',
          userName: data['usuario_nome'] as String? ?? 'Anônimo',
          text: data['comentario'] as String? ?? '',
          rating: data['nota'] as int? ?? data['avaliacao'] as int? ?? 5,
          createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> addComment(LibraryComment comment) async {
    await _firestore.collection('comments').doc(comment.id).set({
      'pdf_id': comment.pdfId,
      'usuario_id': comment.userId,
      'usuario_nome': comment.userName,
      'comentario': comment.text,
      'nota': comment.rating,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------------------------
  // FAVORITES (Bookmarks)
  // ----------------------------------------------------
  Future<List<String>> getFavorites() async {
    if (currentUserId.isEmpty) return [];
    final snapshot = await _firestore.collection('bookmarks')
        .where('usuario_id', isEqualTo: currentUserId)
        .get();
    return snapshot.docs.map((doc) => doc.data()['pdf_id'] as String).toList();
  }

  Stream<List<String>> watchFavorites() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore.collection('bookmarks')
        .where('usuario_id', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()['pdf_id'] as String).toList());
  }

  Future<void> toggleFavorite(String pdfId) async {
    if (currentUserId.isEmpty) return;
    final snapshot = await _firestore.collection('bookmarks')
        .where('usuario_id', isEqualTo: currentUserId)
        .where('pdf_id', isEqualTo: pdfId)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      // Remove
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      // Add
      await _firestore.collection('bookmarks').add({
        'usuario_id': currentUserId,
        'pdf_id': pdfId,
        'criado_em': FieldValue.serverTimestamp(),
      });
    }
  }

  // ----------------------------------------------------
  // FILE UPLOAD (Firebase Storage)
  // ----------------------------------------------------
  Future<String> uploadPdfFile({
    required String pdfId,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    final storagePath = 'community_pdfs/$currentUserId/$pdfId';
    final ref = _storage.ref(storagePath);
    if (fileBytes != null) {
      await ref.putData(fileBytes, SettableMetadata(contentType: 'application/pdf'));
    } else if (filePath != null) {
      await ref.putFile(File(filePath), SettableMetadata(contentType: 'application/pdf'));
    } else {
      throw Exception('Nenhum arquivo ou byte fornecido para upload');
    }
    return storagePath;
  }

  Future<void> deleteUploadedPdfFile(String storagePath) async {
    await _storage.ref(storagePath).delete();
  }

  Future<Uint8List> getPdfBytes(PdfDocument pdf) async {
    if (pdf.storagePath.isNotEmpty) {
      final bytes = await _storage.ref(pdf.storagePath).getData(50 * 1024 * 1024);
      if (bytes == null) throw Exception('Não foi possível carregar o arquivo PDF');
      return bytes;
    }
    if (pdf.fileUrl.isEmpty) throw Exception('Arquivo PDF indisponível');
    final response = await Dio().get<List<int>>(
      pdf.fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null) throw Exception('Não foi possível carregar o arquivo PDF');
    return Uint8List.fromList(bytes);
  }

  Future<String> uploadThumbnailFile(String filePath, String fileName) async {
    final ref = _storage.ref().child('thumbnails/$fileName');
    final uploadTask = await ref.putFile(File(filePath));
    return await uploadTask.ref.getDownloadURL();
  }
}
