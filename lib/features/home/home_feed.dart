import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeFeed extends ConsumerWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfs = ref.watch(pdfsProvider);
    final favorites = ref.watch(favoritesProvider);

    // Filter PDFs sent by clients
    final clientPdfs = pdfs.where((pdf) => pdf.createdBy == 'cliente').toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // App bar inset lives INSIDE the scroll so it scrolls away and the
          // feed slides under the frosted bar (overlay pattern).
          SizedBox(
            height: kasyAppBarBodyTopOverlap(context) +
                KasySpacing.belowChromeContentGap,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with "Meus PDFs" title and "Enviar PDF" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.library.my_pdfs,
                      style: context.kasyTextTheme.pageTitle,
                    ),
                    KasyButton(
                      label: t.library.send_pdf,
                      icon: Icons.upload_file,
                      onPressed: () => context.push('/library/admin/cadastrar-pdf'),
                    ),
                  ],
                ),
                const SizedBox(height: KasySpacing.lg),

                // PDFs List/Grid
                if (clientPdfs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: KasySpacing.xxl),
                    child: KasyEmptyState(
                      title: t.library.no_client_pdfs,
                      subtitle: t.library.no_comments, // Reuse or fallback subtitle
                      icon: Icons.picture_as_pdf_outlined,
                      action: KasyButton(
                        label: t.library.send_pdf,
                        icon: Icons.add,
                        variant: KasyButtonVariant.secondary,
                        onPressed: () => context.push('/library/admin/cadastrar-pdf'),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisSpacing: KasySpacing.md,
                      crossAxisSpacing: KasySpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: clientPdfs.length,
                    itemBuilder: (context, index) {
                      final pdf = clientPdfs[index];
                      final isFav = favorites.contains(pdf.id);

                      return KasyCard(
                        onTap: () => context.push('/library/pdf/${pdf.id}'),
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Thumbnail
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(KasyRadius.lg),
                                    ),
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
                                  Positioned(
                                    top: KasySpacing.xs,
                                    right: KasySpacing.xs,
                                    child: IconButton(
                                      icon: Icon(
                                        isFav ? Icons.bookmark : Icons.bookmark_border,
                                        color: isFav ? context.colors.primary : context.colors.muted,
                                      ),
                                      onPressed: () {
                                        ref.read(favoritesProvider.notifier).toggleFavorite(pdf.id);
                                        showKasyToast(
                                          context,
                                          title: isFav ? 'Removido dos favoritos' : 'Adicionado aos favoritos',
                                          tone: KasyToastTone.success,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Details
                            Padding(
                              padding: const EdgeInsets.all(KasySpacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pdf.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.kasyTextTheme.cardTitle,
                                  ),
                                  const SizedBox(height: KasySpacing.xs),
                                  Text(
                                    pdf.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.kasyTextTheme.cardSubtitle,
                                  ),
                                  const SizedBox(height: KasySpacing.xs),
                                  Wrap(
                                    spacing: KasySpacing.xs,
                                    runSpacing: KasySpacing.xs,
                                    children: pdf.tags.take(2).map((t) {
                                      return KasyTag(label: t);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xxl),
        ],
      ),
    );
  }
}
