import 'dart:typed_data';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/library_firebase_repository.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart' hide PdfDocument;

class PdfReaderPage extends ConsumerStatefulWidget {
  final String pdfId;

  const PdfReaderPage({super.key, required this.pdfId});

  @override
  ConsumerState<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends ConsumerState<PdfReaderPage> {
  String? _loadedPdfId;
  Future<Uint8List>? _pdfBytesFuture;

  @override
  Widget build(BuildContext context) {
    final pdfsAsync = ref.watch(pdfsProvider);

    return pdfsAsync.when(
      data: (pdfs) {
        final PdfDocument? pdf = pdfs.cast<PdfDocument?>().firstWhere(
              (item) => item?.id == widget.pdfId,
              orElse: () => null,
            );
        if (pdf == null) {
          return _messageScreen(
            title: t.library.pdf_not_found,
            subtitle: t.library.private_pdf_unavailable,
          );
        }

        if (_loadedPdfId != pdf.id) {
          _loadedPdfId = pdf.id;
          _pdfBytesFuture = ref.read(libraryFirebaseRepositoryProvider).getPdfBytes(pdf);
        }

        return KasyScreen(
          scrollable: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
            child: KasyAppBar(
              title: pdf.title,
              onBack: () => context.pop(),
            ),
          ),
          child: FutureBuilder<Uint8List>(
            future: _pdfBytesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: KasyEmptyState(
                    title: t.library.pdf_load_error,
                    subtitle: snapshot.error?.toString() ?? t.library.private_pdf_unavailable,
                    icon: Icons.error_outline,
                  ),
                );
              }
              return PdfViewer.data(
                snapshot.data!,
                sourceName: pdf.storagePath.isNotEmpty ? pdf.storagePath : pdf.id,
              );
            },
          ),
        );
      },
      loading: () => _loadingScreen(),
      error: (error, stackTrace) => _messageScreen(
        title: t.library.pdf_load_error,
        subtitle: error.toString(),
      ),
    );
  }

  Widget _loadingScreen() {
    return KasyScreen(
      scrollable: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: t.library.read,
          onBack: () => context.pop(),
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _messageScreen({required String title, required String subtitle}) {
    return KasyScreen(
      scrollable: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: t.library.read,
          onBack: () => context.pop(),
        ),
      ),
      child: Center(
        child: KasyEmptyState(
          title: title,
          subtitle: subtitle,
          icon: Icons.picture_as_pdf_outlined,
        ),
      ),
    );
  }
}
