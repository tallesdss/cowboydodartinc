import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilesPage extends ConsumerWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfs = ref.watch(pdfsProvider);

    // Extract unique authors (uploaders)
    final uniqueAuthors = pdfs.map((pdf) => pdf.author).toSet().toList();

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarToolbarRowHeight),
        child: KasyAppBar(
          title: t.library.public_profile,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Explore os perfis dos criadores de conteúdo',
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),
          if (uniqueAuthors.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: KasySpacing.xl),
              child: KasyEmptyState(
                title: 'Nenhum perfil encontrado',
                subtitle: 'Nenhum usuário publicou PDFs ainda.',
                icon: Icons.people_outline,
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
                childAspectRatio: 1.3,
              ),
              itemCount: uniqueAuthors.length,
              itemBuilder: (context, index) {
                final author = uniqueAuthors[index];
                final authorPdfsCount = pdfs.where((p) => p.author == author).length;

                return KasyCard(
                  onTap: () => context.push('/library/uploader/${Uri.encodeComponent(author)}'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: context.colors.primary.withAlpha(20),
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: KasySpacing.sm),
                      Text(
                        author,
                        style: context.kasyTextTheme.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: KasySpacing.xs),
                      Text(
                        '$authorPdfsCount ${t.library.pdfs.toLowerCase()}',
                        style: context.kasyTextTheme.cardSubtitle,
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
