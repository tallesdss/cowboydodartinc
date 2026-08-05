import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  String _searchQuery = '';
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final pdfs = ref.watch(pdfsProvider);
    final favorites = ref.watch(favoritesProvider);
    final categories = ref.watch(categoriesProvider);

    // Other users: any PDF where createdBy != activeProfile
    final otherUsersPdfs = pdfs.where((pdf) {
      final isFromOther = pdf.createdBy != activeProfile;
      final matchesSearch = pdf.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pdf.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pdf.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory = _selectedCategoryId == 'all' || pdf.categoryIds.contains(_selectedCategoryId);
      return isFromOther && matchesSearch && matchesCategory;
    }).toList();

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarToolbarRowHeight),
        child: KasyAppBar(
          title: t.library.explore,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          KasyTextField(
            hint: t.library.search_hint,
            prefix: Icon(
              Icons.search,
              size: KasyTextField.iconGlyphSize,
              color: context.colors.muted,
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: KasySpacing.md),

          // Categories horizontal list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                KasySelectableChip(
                  key: const ValueKey('cat-explore-all'),
                  label: 'Todos os Temas',
                  selected: _selectedCategoryId == 'all',
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = 'all';
                    });
                  },
                ),
                ...categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: KasySpacing.sm),
                    child: KasySelectableChip(
                      key: ValueKey('cat-explore-${cat.id}'),
                      label: cat.name,
                      selected: _selectedCategoryId == cat.id,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.lg),

          // Public PDFs Grid
          if (otherUsersPdfs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: KasySpacing.xl),
              child: KasyEmptyState(
                title: t.library.no_public_pdfs,
                subtitle: 'Nenhum documento público de outros usuários corresponde à busca.',
                icon: Icons.explore_outlined,
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
              itemCount: otherUsersPdfs.length,
              itemBuilder: (context, index) {
                final pdf = otherUsersPdfs[index];
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
                            // Clickable Uploader/Author Name
                            GestureDetector(
                              onTap: () => context.push('/library/uploader/${Uri.encodeComponent(pdf.author)}'),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  '${t.library.uploaded_by}: ${pdf.author}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.kasyTextTheme.cardSubtitle.copyWith(
                                    color: context.colors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
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
}
