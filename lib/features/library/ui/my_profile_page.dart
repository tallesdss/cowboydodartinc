import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateNotifierProvider).user;
    final pdfs = ref.watch(pdfsProvider).valueOrNull ?? [];

    final isAdmin = userState.isAdmin;
    final profileName = (userState is AuthenticatedUserData && userState.name != null)
        ? userState.name!
        : (isAdmin ? 'Admin / Dev' : 'Cliente');

    // Get PDFs uploaded by this profile
    final myPdfs = pdfs.where((pdf) => pdf.createdBy == userState.idOrNull).toList();

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: t.library.my_pdfs,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Details Card
          KasyCard(
            padding: const EdgeInsets.all(KasySpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: context.colors.primary.withAlpha(20),
                  child: Text(
                    profileName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
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
                        profileName,
                        style: context.kasyTextTheme.pageTitle.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: KasySpacing.xs),
                      Text(
                        isAdmin ? 'Administrador do Sistema' : 'Leitor & Colaborador',
                        style: context.kasyTextTheme.cardSubtitle.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: KasySpacing.xs),
                      Text(
                        '${myPdfs.length} PDFs publicados',
                        style: context.kasyTextTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xl),

          // Upload Button
          KasyButton(
            label: t.library.send_pdf,
            icon: Icons.cloud_upload,
            onPressed: () => context.push('/library/admin/cadastrar-pdf'),
          ),
          const SizedBox(height: KasySpacing.xl),

          // Section Title
          Text(
            'Meus Envios',
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),

          // List of User's Uploaded PDFs
          if (myPdfs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: KasySpacing.xl),
              child: KasyEmptyState(
                title: t.library.no_pdfs,
                subtitle: 'Você ainda não enviou nenhum arquivo PDF.',
                icon: Icons.upload_file,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPdfs.length,
              itemBuilder: (context, index) {
                final pdf = myPdfs[index];

                return KasyCard(
                  margin: const EdgeInsets.only(bottom: KasySpacing.md),
                  onTap: () => context.push('/library/pdf/${pdf.id}'),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(KasyRadius.md),
                        child: Image.network(
                          pdf.thumbnailUrl,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 70,
                            color: context.colors.surfaceSecondary,
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: context.colors.muted,
                            ),
                          ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: KasySpacing.xs),
                            Text(
                              pdf.author,
                              style: context.kasyTextTheme.cardSubtitle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: KasySpacing.sm),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: context.colors.error),
                        onPressed: () {
                          showKasyConfirmDialog(
                            context,
                            title: 'Excluir PDF?',
                            message: 'Deseja realmente excluir este PDF da biblioteca?',
                            cancelLabel: t.library.cancel,
                            confirmLabel: t.library.delete_pdf,
                            destructive: true,
                            onConfirmAsync: () async {
                              await ref.read(pdfsProvider.notifier).deletePdf(pdf.id);
                              if (context.mounted) {
                                showKasyToast(
                                  context,
                                  title: 'PDF removido com sucesso!',
                                  tone: KasyToastTone.success,
                                );
                              }
                            },
                          );
                        },
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
