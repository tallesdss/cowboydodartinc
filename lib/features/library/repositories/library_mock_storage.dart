import 'dart:convert';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/notifications_entity.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/repositories/mock_notifications_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryMockStorageProvider = Provider<LibraryMockStorage>((ref) {
  final prefsBuilder = ref.watch(sharedPreferencesProvider);
  final notifRepo = ref.watch(mockNotificationRepositoryProvider) as MockNotificationsRepository;
  return LibraryMockStorage(prefsBuilder, notifRepo);
});

class LibraryMockStorage {
  final SharedPreferencesBuilder _prefsBuilder;
  final MockNotificationsRepository _notifRepo;

  LibraryMockStorage(this._prefsBuilder, this._notifRepo);

  static const _keyCategories = 'library_mock_categories';
  static const _keyPdfs = 'library_mock_pdfs';
  static const _keyComments = 'library_mock_comments';
  static const _keyFavorites = 'library_mock_favorites';
  static const _keyActiveProfile = 'library_active_profile';

  // ----------------------------------------------------
  // PROFILE SELECTION (Admin/Developer vs Cliente)
  // ----------------------------------------------------
  Future<void> saveActiveProfile(String profile) async {
    await _prefsBuilder.prefs.setString(_keyActiveProfile, profile);
  }

  String getActiveProfile() {
    return _prefsBuilder.prefs.getString(_keyActiveProfile) ?? 'cliente';
  }

  // ----------------------------------------------------
  // CATEGORIES
  // ----------------------------------------------------
  List<LibraryCategory> getCategories() {
    final raw = _prefsBuilder.prefs.getString(_keyCategories);
    if (raw == null) {
      final initial = _getInitialCategories();
      saveCategories(initial);
      return initial;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => LibraryCategory.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCategories(List<LibraryCategory> categories) async {
    final encoded = jsonEncode(categories.map((c) => c.toMap()).toList());
    await _prefsBuilder.prefs.setString(_keyCategories, encoded);
  }

  Future<void> addCategory(LibraryCategory category) async {
    final list = getCategories();
    list.add(category);
    await saveCategories(list);
  }

  Future<void> deleteCategory(String id) async {
    final list = getCategories();
    list.removeWhere((c) => c.id == id);
    await saveCategories(list);
  }

  Future<void> updateCategory(LibraryCategory updated) async {
    final list = getCategories();
    final index = list.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      list[index] = updated;
      await saveCategories(list);
    }
  }

  // ----------------------------------------------------
  // PDFS
  // ----------------------------------------------------
  List<PdfDocument> getPdfs() {
    final raw = _prefsBuilder.prefs.getString(_keyPdfs);
    if (raw == null) {
      final initial = _getInitialPdfs();
      savePdfs(initial);
      return initial;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => PdfDocument.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> savePdfs(List<PdfDocument> pdfs) async {
    final encoded = jsonEncode(pdfs.map((p) => p.toMap()).toList());
    await _prefsBuilder.prefs.setString(_keyPdfs, encoded);
  }

  Future<void> addPdf(PdfDocument pdf) async {
    final list = getPdfs();
    list.add(pdf);
    await savePdfs(list);
  }

  Future<void> deletePdf(String id) async {
    final list = getPdfs();
    list.removeWhere((p) => p.id == id);
    await savePdfs(list);
  }

  // ----------------------------------------------------
  // COMMENTS
  // ----------------------------------------------------
  List<LibraryComment> getComments(String pdfId) {
    final raw = _prefsBuilder.prefs.getString(_keyComments);
    if (raw == null) {
      final initial = _getInitialComments();
      saveComments(initial);
      return initial.where((c) => c.pdfId == pdfId).toList();
    }
    final decoded = jsonDecode(raw) as List;
    final allComments = decoded.map((e) => LibraryComment.fromMap(e as Map<String, dynamic>)).toList();
    return allComments.where((c) => c.pdfId == pdfId).toList();
  }

  Future<void> saveComments(List<LibraryComment> comments) async {
    final encoded = jsonEncode(comments.map((c) => c.toMap()).toList());
    await _prefsBuilder.prefs.setString(_keyComments, encoded);
  }

  Future<void> addComment(LibraryComment comment) async {
    final raw = _prefsBuilder.prefs.getString(_keyComments);
    List<LibraryComment> allComments = [];
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      allComments = decoded.map((e) => LibraryComment.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      allComments = _getInitialComments();
    }
    allComments.add(comment);
    await saveComments(allComments);

    // Enviar notificação se for em PDF de outro usuário
    final pdfs = getPdfs();
    final pdfIndex = pdfs.indexWhere((p) => p.id == comment.pdfId);
    if (pdfIndex != -1) {
      final pdf = pdfs[pdfIndex];
      if (pdf.createdBy != comment.userName) {
        final notification = Notification.withData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: t.notifications.new_comment_title,
          body: t.notifications.new_comment_body.replaceAll('{pdfTitle}', pdf.title),
          createdAt: DateTime.now(),
          type: NotificationTypes.OTHER,
          data: {
            'route': '/library/${pdf.id}',
            'pdfId': pdf.id,
            'commentId': comment.id,
          },
        );
        await _notifRepo.createNotification(pdf.createdBy, notification);
      }
    }
  }

  // ----------------------------------------------------
  // FAVORITES
  // ----------------------------------------------------
  List<String> getFavorites() {
    return _prefsBuilder.prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> toggleFavorite(String pdfId) async {
    final list = getFavorites();
    if (list.contains(pdfId)) {
      list.remove(pdfId);
    } else {
      list.add(pdfId);
    }
    await _prefsBuilder.prefs.setStringList(_keyFavorites, list);
  }

  // ----------------------------------------------------
  // INITIAL SEEDS
  // ----------------------------------------------------
  List<LibraryCategory> _getInitialCategories() {
    return [
      LibraryCategory(
        id: 'cat_dev',
        name: 'Desenvolvimento de Software',
        description: 'Tudo sobre programação, Flutter, arquitetura e clean code.',
        icon: 'code',
        color: 'primary',
        createdAt: DateTime.now(),
      ),
      LibraryCategory(
        id: 'cat_design',
        name: 'Design & UX',
        description: 'Guias visuais, teoria das cores, usabilidade e design systems.',
        icon: 'design',
        color: 'warning',
        createdAt: DateTime.now(),
      ),
      LibraryCategory(
        id: 'cat_business',
        name: 'Negócios & Gestão',
        description: 'Metodologias ágeis, liderança, empreendedorismo e estratégia.',
        icon: 'trendingUp',
        color: 'success',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<PdfDocument> _getInitialPdfs() {
    return [
      PdfDocument(
        id: 'pdf_flutter_init',
        title: 'Flutter para Iniciantes',
        description: 'Aprenda Flutter do zero, construindo seu primeiro aplicativo móvel e web passo a passo com design moderno.',
        categoryIds: const ['cat_dev'],
        author: 'Elena Park',
        fileUrl: 'assets/docs/flutter_init.pdf',
        thumbnailUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80',
        tags: const ['Flutter', 'Dart', 'Mobile', 'Web'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        createdBy: 'admin',
        views: 1250,
        downloads: 340,
      ),
      PdfDocument(
        id: 'pdf_kasy_ds',
        title: 'Kasy Design System Guide',
        description: 'Guia completo de tokens, componentes e responsividade do Kasy Design System para criar telas de alto padrão visual.',
        categoryIds: const ['cat_design'],
        author: 'Marcus Vale',
        fileUrl: 'assets/docs/kasy_ds_guide.pdf',
        thumbnailUrl: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=400&q=80',
        tags: const ['Design System', 'UI/UX', 'Figma'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'admin',
        views: 845,
        downloads: 120,
      ),
      PdfDocument(
        id: 'pdf_agile',
        title: 'Metodologias Ágeis no Dia a Dia',
        description: 'Como aplicar Scrum e Kanban para aumentar a produtividade e o foco das equipes de tecnologia.',
        categoryIds: const ['cat_business'],
        author: 'Sofia Reis',
        fileUrl: 'assets/docs/agile_methods.pdf',
        thumbnailUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
        tags: const ['Agile', 'Scrum', 'Kanban', 'Management'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'admin',
        views: 432,
        downloads: 50,
      ),
    ];
  }

  List<LibraryComment> _getInitialComments() {
    return [
      LibraryComment(
        id: 'comm_1',
        pdfId: 'pdf_flutter_init',
        userName: 'João Silva',
        text: 'Excelente livro! O conteúdo de introdução ao Dart e Flutter é muito claro.',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      LibraryComment(
        id: 'comm_2',
        pdfId: 'pdf_flutter_init',
        userName: 'Maria Souza',
        text: 'Bom guia, mas poderia ter mais exemplos avançados de gerência de estado.',
        rating: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      LibraryComment(
        id: 'comm_3',
        pdfId: 'pdf_kasy_ds',
        userName: 'Lucas Tech',
        text: 'Essencial para quem trabalha com o Kasy Design System. Facilita muito o trabalho.',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
