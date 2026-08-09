import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/global_search_provider.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GlobalSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const GlobalSearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _query = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(globalSearchResultsProvider(_query));

    return KasyOverlayScaffold(
      title: t.search.title,
      appBarStyle: KasyAppBarStyle.subpageSimple,
      maxContentWidth: 600,
      onBack: () => context.pop(),
      // Customizamos o applicationBar para o desktop
      applicationBar: (base) => base.copyWith(
        showSearch: true,
        searchController: _searchController,
        searchHint: t.search.hint,
        onSearchChanged: _onSearchChanged,
      ),
      slivers: [
        // No mobile/tablet, a barra de pesquisa fica no topo do conteúdo, 
        // já que o KasyAppBar no mobile não exibe a barra da application.
        // Ocultamos a barra duplicada no desktop via MediaQuery.
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
              if (isDesktop) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: KasySpacing.lg),
                child: KasyTextField(
                  controller: _searchController,
                  hint: t.search.hint,
                  autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
                  prefix: Icon(Icons.search, size: KasyTextField.iconGlyphSize, color: context.colors.muted),
                  onChanged: _onSearchChanged,
                ),
              );
            },
          ),
        ),

        if (_query.trim().isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KasyEmptyState(
              icon: Icons.search,
              title: t.search.title,
              subtitle: t.search.hint,
            ),
          )
        else if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KasyEmptyState(
              icon: Icons.search_off,
              title: t.search.title,
              subtitle: t.search.empty.replaceAll('{query}', _query),
            ),
          )
        else ...[
          // Autores
          if (results.authors.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: KasySpacing.md),
                child: Text(t.search.authors, style: context.kasyTextTheme.sectionTitle),
              ),
            ),
            SliverToBoxAdapter(
              child: Wrap(
                spacing: KasySpacing.sm,
                runSpacing: KasySpacing.sm,
                children: results.authors.map((author) {
                  return GestureDetector(
                    onTap: () {},
                    child: KasyChip(
                      label: author,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: KasySpacing.xl)),
          ],

          // Temas
          if (results.categories.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: KasySpacing.md),
                child: Text(t.search.categories, style: context.kasyTextTheme.sectionTitle),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 96,
                mainAxisSpacing: KasySpacing.md,
                crossAxisSpacing: KasySpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = results.categories[index];
                  return KasyCard(
                    padding: const EdgeInsets.all(KasySpacing.md),
                    onTap: () {
                      context.pop();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.name,
                          style: context.kasyTextTheme.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
                childCount: results.categories.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: KasySpacing.xl)),
          ],

          // PDFs
          if (results.pdfs.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: KasySpacing.md),
                child: Text(t.search.pdfs, style: context.kasyTextTheme.sectionTitle),
              ),
            ),
            SliverList.separated(
              itemCount: results.pdfs.length,
              itemBuilder: (context, index) {
                final pdf = results.pdfs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2), // Padding para não cortar sombra
                  child: KasyCard(
                    padding: EdgeInsets.zero,
                    onTap: () => context.push('/pdf/${pdf.id}'),
                    child: ListTile(
                      leading: KasyAvatar(initials: pdf.title.substring(0, 1).toUpperCase()),
                      title: Text(pdf.title, style: context.kasyTextTheme.labelLarge),
                      subtitle: Text(pdf.author, style: context.kasyTextTheme.bodySmall),
                      trailing: Icon(Icons.chevron_right, color: context.colors.muted),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: KasySpacing.sm),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: KasySpacing.xl)),
          ]
        ]
      ],
    );
  }
}
