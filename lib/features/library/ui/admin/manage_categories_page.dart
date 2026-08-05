import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageCategoriesPage extends ConsumerStatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  ConsumerState<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends ConsumerState<ManageCategoriesPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    if (name.isEmpty || desc.isEmpty) {
      showKasyToast(
        context,
        title: 'Preencha todos os campos!',
        tone: KasyToastTone.warning,
      );
      return;
    }

    ref.read(categoriesProvider.notifier).addCategory(name, desc);
    _nameController.clear();
    _descController.clear();

    showKasyToast(
      context,
      title: 'Categoria adicionada com sucesso!',
      tone: KasyToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final categories = ref.watch(categoriesProvider);

    if (activeProfile != 'admin') {
      return KasyScreen(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kasyAppBarToolbarRowHeight),
          child: KasyAppBar(title: 'Acesso Negado'),
        ),
        child: Center(
          child: Text(t.library.unauthorized),
        ),
      );
    }

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarToolbarRowHeight),
        child: KasyAppBar(
          title: t.library.manage_categories,
          onBack: () => context.pop(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Create Category Form
          KasyCard(
            variant: KasyCardVariant.filled,
            padding: const EdgeInsets.all(KasySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.library.add_category,
                  style: context.kasyTextTheme.sectionTitle,
                ),
                const SizedBox(height: KasySpacing.md),
                KasyTextField(
                  variant: KasyTextFieldVariant.flat,
                  controller: _nameController,
                  label: t.library.category_name,
                ),
                const SizedBox(height: KasySpacing.md),
                KasyTextField(
                  variant: KasyTextFieldVariant.flat,
                  controller: _descController,
                  label: t.library.category_desc,
                ),
                const SizedBox(height: KasySpacing.lg),
                KasyButton(
                  label: t.library.save,
                  variant: KasyButtonVariant.primary,
                  onPressed: _addCategory,
                ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xl),

          Text(
            'Categorias Cadastradas',
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.md),

          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: KasySpacing.lg),
              child: Text('Nenhuma categoria cadastrada.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];

                return KasyCard(
                  variant: KasyCardVariant.elevated,
                  margin: const EdgeInsets.only(bottom: KasySpacing.md),
                  padding: const EdgeInsets.all(KasySpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: context.kasyTextTheme.rowTitle,
                            ),
                            if (cat.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                cat.description,
                                style: context.kasyTextTheme.caption.copyWith(
                                  color: context.colors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: context.colors.primary,
                        ),
                        onPressed: () {
                          showKasyConfirmDialog(
                            context,
                            title: t.library.delete_category,
                            message: 'Tem certeza que deseja excluir esta categoria? Os PDFs associados não serão apagados, mas perderão este vínculo.',
                            confirmLabel: 'Excluir',
                            cancelLabel: 'Cancelar',
                            onConfirm: () {
                              ref.read(categoriesProvider.notifier).deleteCategory(cat.id);
                              showKasyToast(
                                context,
                                title: 'Categoria excluída!',
                                tone: KasyToastTone.success,
                              );
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
