import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_provider.g.dart';

class GlobalSearchResults {
  final List<PdfDocument> pdfs;
  final List<LibraryCategory> categories;
  final List<String> authors;

  const GlobalSearchResults({
    required this.pdfs,
    required this.categories,
    required this.authors,
  });

  bool get isEmpty => pdfs.isEmpty && categories.isEmpty && authors.isEmpty;
}

@riverpod
GlobalSearchResults globalSearchResults(Ref ref, String query) {
  if (query.trim().isEmpty) {
    return const GlobalSearchResults(pdfs: [], categories: [], authors: []);
  }
  
  final q = query.trim().toLowerCase();
  
  final allPdfs = ref.watch(pdfsProvider).valueOrNull ?? [];
  final allCategories = ref.watch(categoriesProvider).valueOrNull ?? [];
  
  final List<PdfDocument> pdfs = allPdfs.where((PdfDocument pdf) => 
    pdf.title.toLowerCase().contains(q) ||
    pdf.description.toLowerCase().contains(q) ||
    pdf.author.toLowerCase().contains(q) ||
    pdf.tags.any((String tag) => tag.toLowerCase().contains(q))
  ).toList();
  
  final List<LibraryCategory> categories = allCategories.where((LibraryCategory cat) =>
    cat.name.toLowerCase().contains(q) ||
    cat.description.toLowerCase().contains(q)
  ).toList();
  
  // Extrai os autores unicos dos PDFs (pois quem envia um PDF vira "autor")
  final Set<String> allAuthors = allPdfs.map((PdfDocument p) => p.author).toSet();
  final List<String> authors = allAuthors.where((String a) => a.toLowerCase().contains(q)).toList();
  
  return GlobalSearchResults(
    pdfs: pdfs,
    categories: categories,
    authors: authors,
  );
}
