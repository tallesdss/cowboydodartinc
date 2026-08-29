import 'dart:async';
import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _HomeCategoryAll {
  static const id = 'all';
}

class _HomeCategoryFavorites {
  static const id = 'favorites';
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  String _searchQuery = '';
  String _selectedCategoryId = _HomeCategoryAll.id;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _simulateLoading(1200);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _simulateLoading(int ms) {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onSearchChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = val;
        });
        _simulateLoading(400);
      }
    });
  }

  void _selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _simulateLoading(500);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final pdfs = ref.watch(pdfsProvider).value ?? [];
    final favorites = ref.watch(favoritesProvider).value ?? [];

    final isAdmin = ref.watch(userStateNotifierProvider).user.isAdmin;

    // Filter PDFs
    final filteredPdfs = pdfs.where((pdf) {
      final matchesSearch = pdf.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pdf.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pdf.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = _selectedCategoryId == _HomeCategoryAll.id ||
          (_selectedCategoryId == _HomeCategoryFavorites.id && favorites.contains(pdf.id)) ||
          pdf.categoryIds.contains(_selectedCategoryId);

      return matchesSearch && matchesCategory;
    }).toList();

    return KasyAppBarConfigurator(
      configure: (base) => base.copyWith(
        showSearch: true,
        searchHint: t.search.hint,
        onSearchSubmitted: (val) {
          if (val.trim().isNotEmpty) {
            context.push('/search?q=${Uri.encodeComponent(val)}');
          } else {
            context.push('/search');
          }
        },
      ),
      child: KasyScreen(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
          child: KasyAppBar(
            title: t.library.title,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KasyChromeOrbIconButton(
                  icon: Icons.search,
                  iconSize: 20,
                  foregroundColor: context.colors.primary,
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                const SizedBox(width: KasySpacing.xs),
                Text(
                  isAdmin ? t.library.admin_dev : t.library.client,
                  style: context.kasyTextTheme.labelMedium.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        child: DeviceSizeBuilder(
          builder: (device) {
            final isSmall = device == DeviceType.small;
            final isMedium = device == DeviceType.medium;

            return Column(
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
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: KasySpacing.lg),

                // Categories Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      KasySelectableChip(
                        key: const ValueKey('cat-all'),
                        label: 'Todos',
                        selected: _selectedCategoryId == _HomeCategoryAll.id,
                        onTap: () => _selectCategory(_HomeCategoryAll.id),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: KasySpacing.sm),
                        child: KasySelectableChip(
                          key: const ValueKey('cat-favorites'),
                          label: t.library.favorites,
                          selected: _selectedCategoryId == _HomeCategoryFavorites.id,
                          onTap: () => _selectCategory(_HomeCategoryFavorites.id),
                        ),
                      ),
                      ...categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(left: KasySpacing.sm),
                          child: KasySelectableChip(
                            key: ValueKey(cat.id),
                            label: cat.name,
                            selected: _selectedCategoryId == cat.id,
                            onTap: () => _selectCategory(cat.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: KasySpacing.lg),

                // Admin buttons if Admin/Dev
                if (isAdmin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: KasyButton(
                          label: t.library.add_pdf,
                          icon: Icons.add,
                          onPressed: () => context.push('/library/admin/cadastrar-pdf'),
                        ),
                      ),
                      const SizedBox(width: KasySpacing.md),
                      Expanded(
                        child: KasyButton(
                          label: t.library.manage_categories,
                          icon: Icons.category,
                          variant: KasyButtonVariant.secondary,
                          onPressed: () => context.push('/library/admin/categorias'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KasySpacing.lg),
                ] else ...[
                  KasyButton(
                    label: t.library.send_pdf,
                    icon: Icons.cloud_upload,
                    onPressed: () => context.push('/library/admin/cadastrar-pdf'),
                  ),
                  const SizedBox(height: KasySpacing.lg),
                ],

                // PDF Documents Grid
                if (_isLoading)
                  const _PdfsGridSkeleton()
                else if (filteredPdfs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: KasySpacing.xl),
                    child: KasyEmptyState(
                      title: t.library.no_pdfs,
                      subtitle: 'Tente mudar o filtro de categoria ou termo de busca.',
                      icon: Icons.picture_as_pdf_outlined,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmall ? 2 : (isMedium ? 3 : 4),
                      mainAxisSpacing: KasySpacing.md,
                      crossAxisSpacing: KasySpacing.md,
                      childAspectRatio: isSmall ? 0.7 : 0.75,
                    ),
                    itemCount: filteredPdfs.length,
                    itemBuilder: (context, index) {
                      final pdf = filteredPdfs[index];
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
            );
          },
        ),
      ),
    );
  }
}

class _PdfsGridSkeleton extends StatelessWidget {
  const _PdfsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return DeviceSizeBuilder(
      builder: (device) {
        final isSmall = device == DeviceType.small;
        final isMedium = device == DeviceType.medium;

        return KasySkeletonGroup(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmall ? 2 : (isMedium ? 3 : 4),
              mainAxisSpacing: KasySpacing.md,
              crossAxisSpacing: KasySpacing.md,
              childAspectRatio: isSmall ? 0.7 : 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const KasyCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: KasySkeleton(
                        width: double.infinity,
                        height: 100, // height parameter is required, will be stretched in Expanded
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(KasySpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KasySkeleton(width: 140, height: 16),
                          SizedBox(height: KasySpacing.xs),
                          KasySkeleton(width: 80, height: 12),
                          SizedBox(height: KasySpacing.xs),
                          Row(
                            children: [
                              KasySkeleton(width: 50, height: 18),
                              SizedBox(width: KasySpacing.xs),
                              KasySkeleton(width: 50, height: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
