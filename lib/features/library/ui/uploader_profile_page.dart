import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UploaderProfilePage extends ConsumerWidget {
  final String uploaderName;

  const UploaderProfilePage({super.key, required this.uploaderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfs = ref.watch(pdfsProvider);
    final favorites = ref.watch(favoritesProvider);

    // Get all PDFs by this author
    final uploaderPdfs = pdfs.where((pdf) {
      return pdf.author.trim().toLowerCase() == uploaderName.trim().toLowerCase();
    }).toList();

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: t.library.public_profile,
          onBack: () => context.pop(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
          KasyCard(
            padding: const EdgeInsets.all(KasySpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.primary.withAlpha(20),
                  child: Text(
                    uploaderName.isNotEmpty ? uploaderName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: KasySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploaderName,
                        style: context.kasyTextTheme.pageTitle.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: KasySpacing.sm),
                      // Stats Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatChip(
                              context,
                              icon: Icons.picture_as_pdf,
                              label: '${uploaderPdfs.length} PDFs',
                            ),
                            const SizedBox(width: KasySpacing.sm),
                            _buildStatChip(
                              context,
                              icon: Icons.star,
                              label: '${(uploaderPdfs.length * 0.2 + 4.2).toStringAsFixed(1)} ★',
                            ),
                            const SizedBox(width: KasySpacing.sm),
                            _buildStatChip(
                              context,
                              icon: Icons.visibility,
                              label: '${uploaderPdfs.length * 35 + 12} Visualizações',
                            ),
                            const SizedBox(width: KasySpacing.sm),
                            _buildStatChip(
                              context,
                              icon: Icons.download,
                              label: '${uploaderPdfs.length * 12 + 5} Downloads',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xl),

          // User's PDFs Section Title
          Text(
            t.library.view_all_pdfs,
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),

          // Grid/List of PDFs
          if (uploaderPdfs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: KasySpacing.xl),
              child: KasyEmptyState(
                title: t.library.no_pdfs,
                subtitle: 'Este usuário não possui PDFs públicos cadastrados.',
                icon: Icons.picture_as_pdf_outlined,
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
              itemCount: uploaderPdfs.length,
              itemBuilder: (context, index) {
                final pdf = uploaderPdfs[index];
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
    );
  }

  Widget _buildStatChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.sm, vertical: KasySpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.kasyTextTheme.caption.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
