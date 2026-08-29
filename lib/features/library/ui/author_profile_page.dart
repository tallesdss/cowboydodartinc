import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthorProfilePage extends ConsumerWidget {
  final String authorId;

  const AuthorProfilePage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsAsync = ref.watch(authorsProvider);
    final pdfsAsync = ref.watch(pdfsProvider);

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: 'Perfil do Autor',
          onBack: () => context.pop(),
        ),
      ),
      child: authorsAsync.when(
        data: (authors) {
          final author = authors.firstWhere(
            (a) => a.id == authorId,
            orElse: () => throw Exception('Autor não encontrado'),
          );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: KasySpacing.xl),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: context.colors.primary.withAlpha(40),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: KasySpacing.md),
                    Text(
                      author.name,
                      style: context.kasyTextTheme.pageTitle,
                      textAlign: TextAlign.center,
                    ),
                    if (author.bio.isNotEmpty) ...[
                      const SizedBox(height: KasySpacing.sm),
                      Text(
                        author.bio,
                        style: context.kasyTextTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: KasySpacing.xxl),
                    Divider(color: context.colors.border),
                    const SizedBox(height: KasySpacing.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Obras do Autor',
                        style: context.kasyTextTheme.sectionTitle,
                      ),
                    ),
                    const SizedBox(height: KasySpacing.md),
                  ],
                ),
              ),
              pdfsAsync.when(
                data: (allPdfs) {
                  final authorPdfs = allPdfs.where((p) => p.authorId == author.id || p.author == author.name).toList();

                  if (authorPdfs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Nenhum PDF cadastrado.',
                          style: context.kasyTextTheme.bodyLarge,
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pdf = authorPdfs[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: KasySpacing.md),
                          child: KasyCard(
                            onTap: () => context.push('/library/pdf/${pdf.id}'),
                            padding: const EdgeInsets.all(KasySpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(KasyRadius.md),
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: context.colors.primary,
                                  ),
                                ),
                                const SizedBox(width: KasySpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pdf.title,
                                        style: context.kasyTextTheme.cardTitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: KasySpacing.xs),
                                      Text(
                                        pdf.description,
                                        style: context.kasyTextTheme.cardSubtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: KasySpacing.sm),
                                      GestureDetector(
                                        onTap: () {
                                          context.push('/profile/${pdf.createdBy}');
                                        },
                                        child: Text(
                                          'Enviado por: Perfil do Cadastrador',
                                          style: context.kasyTextTheme.bodyLarge.copyWith(
                                            color: context.colors.primary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: authorPdfs.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverToBoxAdapter(
                  child: Center(child: Text('Erro: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
