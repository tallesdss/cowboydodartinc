import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManagePdfsPage extends ConsumerStatefulWidget {
  const ManagePdfsPage({super.key});

  @override
  ConsumerState<ManagePdfsPage> createState() => _ManagePdfsPageState();
}

class _ManagePdfsPageState extends ConsumerState<ManagePdfsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _authorController = TextEditingController();
  final _thumbController = TextEditingController();
  final _tagsController = TextEditingController();

  final List<String> _selectedCategoryIds = [];

  // Mock Upload Fields
  String? _selectedFileName;
  double? _selectedFileSize;
  int? _selectedPageCount;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _authorController.dispose();
    _thumbController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _savePdf() {
    if (_selectedFileName == null) {
      showKasyToast(
        context,
        title: 'Faça upload de um arquivo PDF primeiro!',
        tone: KasyToastTone.warning,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryIds.isEmpty) {
      showKasyToast(
        context,
        title: 'Selecione pelo menos uma categoria!',
        tone: KasyToastTone.warning,
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final activeProfile = ref.read(activeProfileProvider);

    ref.read(pdfsProvider.notifier).addPdf(
      title: _titleController.text,
      description: _descController.text,
      categoryIds: _selectedCategoryIds,
      author: _authorController.text,
      fileUrl: 'assets/docs/$_selectedFileName',
      thumbnailUrl: _thumbController.text.isNotEmpty
          ? _thumbController.text
          : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80',
      tags: tags,
      createdBy: activeProfile,
    );

    showKasyToast(
      context,
      title: 'PDF cadastrado com sucesso!',
      tone: KasyToastTone.success,
    );

    context.pop();
  }

  void _showMockFilePicker() {
    final List<Map<String, dynamic>> files = [
      {'name': 'Contrato_de_Prestacao_de_Servicos.pdf', 'size': 2.4, 'pages': 6},
      {'name': 'Manual_do_Usuario_Biblioteca_Digital.pdf', 'size': 5.1, 'pages': 14},
      {'name': 'Relatorio_de_Metricas_Q2.pdf', 'size': 1.8, 'pages': 8},
      {'name': 'Guia_Visual_Kasy_Design_System.pdf', 'size': 8.7, 'pages': 24},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KasyRadius.lg),
          ),
          title: Text(
            'Selecione um PDF para simular o upload',
            style: context.kasyTextTheme.sectionTitle,
          ),
          content: SizedBox(
            width: 400,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: files.length,
              separatorBuilder: (context, index) => const SizedBox(height: KasySpacing.sm),
              itemBuilder: (context, index) {
                final file = files[index];
                final name = file['name']?.toString() ?? '';
                final size = file['size'] as double;
                final pages = file['pages'] as int;

                return ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: context.colors.primary,
                    size: 32,
                  ),
                  title: Text(
                    name,
                    style: context.kasyTextTheme.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '$size MB • $pages ${t.library.pages.toLowerCase()}',
                    style: context.kasyTextTheme.cardSubtitle,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.colors.muted,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedFileName = name;
                      _selectedFileSize = size;
                      _selectedPageCount = pages;

                      // Auto-fill some fields to help the user
                      _titleController.text = _selectedFileName!
                          .replaceAll('.pdf', '')
                          .replaceAll('_', ' ');
                      if (_authorController.text.isEmpty) {
                        _authorController.text =
                            ref.read(activeProfileProvider) == 'admin'
                                ? 'Admin / Dev'
                                : 'Cliente';
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t.library.cancel,
                style: TextStyle(color: context.colors.muted),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final isAdmin = activeProfile == 'admin';

    // Auto-fill author if empty
    if (_authorController.text.isEmpty) {
      _authorController.text = isAdmin ? 'Admin / Dev' : 'Cliente';
    }

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: isAdmin ? t.library.add_pdf : t.library.send_pdf,
          onBack: () => context.pop(),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Square
            GestureDetector(
              onTap: _showMockFilePicker,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(KasyRadius.lg),
                  border: Border.all(
                    color: _selectedFileName != null
                        ? context.colors.primary.withAlpha(128)
                        : context.colors.muted.withAlpha(80),
                    width: 2.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KasySpacing.md),
                  child: _selectedFileName == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: context.colors.primary,
                            ),
                            const SizedBox(height: KasySpacing.sm),
                            Text(
                              t.library.upload_box_title,
                              style: context.kasyTextTheme.cardTitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: KasySpacing.xs),
                            Text(
                              t.library.upload_box_subtitle,
                              style: context.kasyTextTheme.cardSubtitle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: context.colors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(KasyRadius.md),
                              ),
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: context.colors.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: KasySpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedFileName!,
                                    style: context.kasyTextTheme.cardTitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: KasySpacing.xs),
                                  Text(
                                    '$_selectedFileSize MB • $_selectedPageCount ${t.library.pages.toLowerCase()}',
                                    style: context.kasyTextTheme.cardSubtitle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: KasySpacing.sm),
                            KasyButton(
                              label: t.library.change_file,
                              variant: KasyButtonVariant.secondary,
                              onPressed: _showMockFilePicker,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: KasySpacing.lg),

            // PDF Page Preview
            if (_selectedPageCount != null) ...[
              Text(
                '${t.library.pdf_preview} ($_selectedPageCount ${t.library.pages.toLowerCase()})',
                style: context.kasyTextTheme.sectionTitle,
              ),
              const SizedBox(height: KasySpacing.sm),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPageCount!,
                  separatorBuilder: (context, index) => const SizedBox(width: KasySpacing.sm),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(KasyRadius.md),
                        border: Border.all(
                          color: context.colors.muted.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(KasySpacing.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(KasyRadius.sm),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 6.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 4,
                                        width: 40,
                                        color: context.colors.muted.withAlpha(80),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 4,
                                        width: 50,
                                        color: context.colors.muted.withAlpha(60),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 4,
                                        width: 30,
                                        color: context.colors.muted.withAlpha(60),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: KasySpacing.xs),
                            Text(
                              'Pág ${index + 1}',
                              style: context.kasyTextTheme.labelSmall.copyWith(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: KasySpacing.lg),
            ],

            KasyTextField(
              controller: _titleController,
              label: t.library.pdf_title,
              validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: KasySpacing.md),
            KasyTextField(
              controller: _descController,
              label: t.library.pdf_desc,
              maxLines: 3,
              validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: KasySpacing.md),
            KasyTextField(
              controller: _authorController,
              label: t.library.pdf_author,
              validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: KasySpacing.md),
            KasyTextField(
              controller: _thumbController,
              label: t.library.pdf_thumb,
              hint: 'URL da Capa (opcional)',
            ),
            const SizedBox(height: KasySpacing.md),
            KasyTextField(
              controller: _tagsController,
              label: t.library.pdf_tags,
              hint: 'Digite as tags separadas por vírgula (ex: Contract, Doc)',
            ),
            const SizedBox(height: KasySpacing.lg),

            Text(
              'Selecione as Categorias',
              style: context.kasyTextTheme.sectionTitle,
            ),
            const SizedBox(height: KasySpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isChecked = _selectedCategoryIds.contains(cat.id);

                return KasyCheckbox(
                  label: cat.name,
                  value: isChecked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedCategoryIds.add(cat.id);
                      } else {
                        _selectedCategoryIds.remove(cat.id);
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: KasySpacing.xl),

            KasyButton(
              label: t.library.save,
              onPressed: _savePdf,
            ),
            const SizedBox(height: KasySpacing.sm),
            KasyButton(
              label: t.library.cancel,
              variant: KasyButtonVariant.ghost,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
