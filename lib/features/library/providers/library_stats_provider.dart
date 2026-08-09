import 'package:cowboydodartinc/features/library/repositories/library_mock_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryStats {
  final int totalPdfs;
  final int totalViews;
  final int totalDownloads;
  final List<UploaderRank> uploaderRanking;

  const LibraryStats({
    required this.totalPdfs,
    required this.totalViews,
    required this.totalDownloads,
    required this.uploaderRanking,
  });
}

class UploaderRank {
  final String author;
  final int pdfCount;

  const UploaderRank({
    required this.author,
    required this.pdfCount,
  });
}

final libraryStatsProvider = Provider<LibraryStats>((ref) {
  final storage = ref.watch(libraryMockStorageProvider);
  final pdfs = storage.getPdfs();

  int views = 0;
  int downloads = 0;
  final Map<String, int> authorCounts = {};

  for (final pdf in pdfs) {
    views += pdf.views;
    downloads += pdf.downloads;
    authorCounts[pdf.author] = (authorCounts[pdf.author] ?? 0) + 1;
  }

  final List<UploaderRank> ranking = authorCounts.entries
      .map((e) => UploaderRank(author: e.key, pdfCount: e.value))
      .toList()
    ..sort((a, b) => b.pdfCount.compareTo(a.pdfCount));

  return LibraryStats(
    totalPdfs: pdfs.length,
    totalViews: views,
    totalDownloads: downloads,
    uploaderRanking: ranking,
  );
});
