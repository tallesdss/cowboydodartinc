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
    final authorsAsync = ref.watch(authorsProvider);
    final pdfs = ref.watch(pdfsProvider).value ?? [];

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: t.library.public_profile,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.library.authors,
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),
          authorsAsync.when(
            data: (authors) {
              if (authors.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: KasySpacing.xl),
                  child: KasyEmptyState(
                    title: t.library.no_authors,
                    subtitle: t.library.no_pdfs,
                    icon: Icons.people_outline,
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: KasySpacing.md,
                  crossAxisSpacing: KasySpacing.md,
                  childAspectRatio: 1.3,
                ),
                itemCount: authors.length,
                itemBuilder: (context, index) {
                  final author = authors[index];
                    final authorPdfsCount = pdfs.where((pdf) => pdf.isPublic &&
                      (pdf.authorId == author.id || pdf.author == author.name)).length;

                  return KasyCard(
                    onTap: () => context.push('/library/author/${author.id}'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: context.colors.primary.withAlpha(20),
                          child: Text(
                            author.name.isNotEmpty ? author.name[0].toUpperCase() : 'A',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: KasySpacing.sm),
                        Text(
                          author.name,
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => KasyEmptyState(
              title: t.library.no_authors,
              subtitle: error.toString(),
              icon: Icons.error_outline,
            ),
          ),
        ],
      ),
    );
  }
}
