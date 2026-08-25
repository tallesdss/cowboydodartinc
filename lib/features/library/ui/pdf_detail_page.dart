import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PdfDetailPage extends ConsumerStatefulWidget {
  final String pdfId;

  const PdfDetailPage({super.key, required this.pdfId});

  @override
  ConsumerState<PdfDetailPage> createState() => _PdfDetailPageState();
}

class _PdfDetailPageState extends ConsumerState<PdfDetailPage> {
  final _commentController = TextEditingController();
  int _userRating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    ref.read(commentsProvider(widget.pdfId).notifier).addComment(
      userName: 'Usuário Logado', // simulated logged-in user name
      text: text,
      rating: _userRating,
    );

    _commentController.clear();
    setState(() {
      _userRating = 5;
    });

    showKasyToast(
      context,
      title: 'Comentário enviado!',
      tone: KasyToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfs = ref.watch(pdfsProvider).valueOrNull ?? [];
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? [];
    final comments = ref.watch(commentsProvider(widget.pdfId)).valueOrNull ?? [];

    final PdfDocument? pdf = pdfs.cast<PdfDocument?>().firstWhere((p) => p?.id == widget.pdfId, orElse: () => null);

    if (pdf == null) {
      return KasyScreen(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kasyAppBarPreferredHeight),
          child: KasyAppBar(
            title: 'Documento não encontrado',
          ),
        ),
        child: Center(
          child: KasyButton(
            label: 'Voltar',
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    final isFav = favorites.contains(pdf.id);

    // Calculate average rating
    double avgRating = 0.0;
    if (comments.isNotEmpty) {
      avgRating = comments.map((c) => c.rating).reduce((a, b) => a + b) / comments.length;
    }

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: pdf.title,
          onBack: () => context.pop(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover and Core Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(KasyRadius.lg),
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: Image.network(
                    pdf.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: context.colors.surfaceSecondary,
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: KasyIconSize.xl,
                        color: context.colors.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KasySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/library/uploader/${Uri.encodeComponent(pdf.author)}'),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          '${t.library.uploaded_by}: ${pdf.author}',
                          style: context.kasyTextTheme.listRowValue.copyWith(
                            color: context.colors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: KasySpacing.xs),
                    // Rating display
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16), // design-check: ignore
                        const SizedBox(width: 4),
                        Text(
                          avgRating > 0 ? avgRating.toStringAsFixed(1) : 'Sem avaliações',
                          style: context.kasyTextTheme.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KasySpacing.xs),
                    // Tags
                    Wrap(
                      spacing: KasySpacing.xs,
                      runSpacing: KasySpacing.xs,
                      children: pdf.tags.map((tag) => KasyTag(label: tag)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.lg),

          // Description
          Text(
            pdf.description,
            style: context.kasyTextTheme.bodyMedium,
          ),
          const SizedBox(height: KasySpacing.xl),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: KasyButton(
                  label: t.library.read,
                  icon: Icons.chrome_reader_mode,
                  onPressed: () => context.push('/library/pdf/${pdf.id}/read'),
                ),
              ),
              const SizedBox(width: KasySpacing.md),
              Expanded(
                child: KasyButton(
                  label: t.library.download,
                  icon: Icons.download,
                  variant: KasyButtonVariant.secondary,
                  onPressed: () {
                    showKasyToast(
                      context,
                      title: 'Download iniciado (simulado)',
                      tone: KasyToastTone.success,
                    );
                  },
                ),
              ),
              const SizedBox(width: KasySpacing.sm),
              KasyChromeOrbIconButton(
                icon: isFav ? Icons.bookmark : Icons.bookmark_border,
                iconSize: 20,
                foregroundColor: isFav ? context.colors.primary : context.colors.onSurface,
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(pdf.id);
                },
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.xl),

          // Comments Section Title
          Text(
            t.library.comments,
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),

          // Add Comment Form
          KasyCard(
            variant: KasyCardVariant.filled,
            padding: const EdgeInsets.all(KasySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      t.library.rating,
                      style: context.kasyTextTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: KasySpacing.md),
                    Row(
                      children: List.generate(5, (index) {
                        final starVal = index + 1;
                        return IconButton(
                          icon: Icon(
                            _userRating >= starVal ? Icons.star : Icons.star_border,
                            color: Colors.amber, // design-check: ignore
                          ),
                          onPressed: () {
                            setState(() {
                              _userRating = starVal;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: KasySpacing.sm),
                KasyTextField(
                  controller: _commentController,
                  variant: KasyTextFieldVariant.flat,
                  hint: t.library.write_comment,
                ),
                const SizedBox(height: KasySpacing.md),
                KasyButton(
                  label: t.library.submit_comment,
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.lg),

          // Comments List
          if (comments.isEmpty)
            Text(
              t.library.no_comments,
              style: context.kasyTextTheme.listRowValue.copyWith(
                color: context.colors.muted,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                return KasyCard(
                  variant: KasyCardVariant.ghost,
                  margin: const EdgeInsets.only(bottom: KasySpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c.userName,
                            style: context.kasyTextTheme.rowTitle,
                          ),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < c.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber, // design-check: ignore
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: KasySpacing.xs),
                      Text(
                        c.text,
                        style: context.kasyTextTheme.bodyMedium,
                      ),
                      const SizedBox(height: KasySpacing.xs),
                      Text(
                        '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                        style: context.kasyTextTheme.caption.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
