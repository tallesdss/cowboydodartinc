import 'dart:typed_data';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/library_firebase_repository.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  final _tagsController = TextEditingController();

  final List<String> _selectedCategoryIds = [];
  LibraryAuthor? _selectedAuthor;

  // Real Upload Fields
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  double? _selectedFileSize;
  
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _savePdf() async {
    if (_selectedFilePath == null && _selectedFileBytes == null) {
      showKasyToast(
        context,
        title: 'Faça upload de um arquivo PDF primeiro!',
        tone: KasyToastTone.warning,
      );
      return;
    }
    if (_selectedAuthor == null) {
      showKasyToast(
        context,
        title: 'Selecione ou crie um autor!',
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

    setState(() => _isUploading = true);

    try {
      final userId = ref.read(userStateNotifierProvider).user.idOrNull ?? 'unknown';
      final repo = ref.read(libraryFirebaseRepositoryProvider);
      
      final downloadUrl = await repo.uploadPdfFile(
        fileName: _selectedFileName!,
        filePath: _selectedFilePath,
        fileBytes: _selectedFileBytes,
      );

      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await ref.read(pdfsProvider.notifier).addPdf(
        title: _titleController.text,
        description: _descController.text,
        categoryIds: _selectedCategoryIds,
        author: _selectedAuthor!.name,
        authorId: _selectedAuthor!.id,
        fileUrl: downloadUrl,
        thumbnailUrl: '',
        tags: tags,
        createdBy: userId,
      );

      if (mounted) {
        showKasyToast(
          context,
          title: 'PDF cadastrado com sucesso!',
          tone: KasyToastTone.success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showKasyToast(
          context,
          title: 'Erro ao fazer upload: $e',
          tone: KasyToastTone.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result != null && (result.files.single.path != null || result.files.single.bytes != null)) {
      final file = result.files.single;
      setState(() {
        _selectedFilePath = file.path;
        _selectedFileBytes = file.bytes;
        _selectedFileName = file.name;
        _selectedFileSize = (file.size / (1024 * 1024)); // MB

        // Auto-fill some fields to help the user
        _titleController.text = _selectedFileName!
            .replaceAll('.pdf', '')
            .replaceAll('_', ' ');
      });
    }
  }

  Future<void> _showCreateAuthorModal() async {
    final nameController = TextEditingController();
    final bioController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showKasyDialog(
      context: context,
      builder: (dialogCtx) => KasyDialog(
        title: 'Novo Autor',
        body: StatefulBuilder(
          builder: (context, setModalState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KasyTextField(
                  controller: nameController,
                  label: 'Nome do Autor',
                  validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: KasySpacing.md),
                KasyTextField(
                  controller: bioController,
                  label: 'Biografia (Opcional)',
                  maxLines: 3,
                ),
                const SizedBox(height: KasySpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    KasyButton(
                      label: t.library.cancel,
                      variant: KasyButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: KasySpacing.md),
                    KasyButton(
                      label: t.library.save,
                      isLoading: isSaving,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        setModalState(() => isSaving = true);
                        try {
                          final userId = ref.read(userStateNotifierProvider).user.idOrNull ?? 'unknown';
                          await ref.read(authorsProvider.notifier).addAuthor(
                            name: nameController.text,
                            bio: bioController.text,
                            createdBy: userId,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop(nameController.text);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showKasyToast(context, title: 'Erro ao salvar autor', tone: KasyToastTone.danger);
                          }
                        } finally {
                          if (context.mounted) {
                            setModalState(() => isSaving = false);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final authorsAsync = ref.watch(authorsProvider);
    final userState = ref.watch(userStateNotifierProvider).user;
    final isAdmin = userState.isAdmin;

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
              onTap: _pickFile,
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
                                    '${_selectedFileSize?.toStringAsFixed(2)} MB',
                                    style: context.kasyTextTheme.cardSubtitle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: KasySpacing.sm),
                            KasyButton(
                              label: t.library.change_file,
                              variant: KasyButtonVariant.secondary,
                              onPressed: _pickFile,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: KasySpacing.lg),

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
            
            // Author Selection
            Text(
              'Autor',
              style: context.kasyTextTheme.labelLarge,
            ),
            const SizedBox(height: KasySpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: authorsAsync.when(
                    data: (authors) {
                      return DropdownButtonFormField<LibraryAuthor>(
                        value: _selectedAuthor,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: KasySpacing.md),
                        ),
                        hint: const Text('Selecione um autor'),
                        items: authors.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a.name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedAuthor = val),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Erro: $e'),
                  ),
                ),
                const SizedBox(width: KasySpacing.sm),
                KasyButton(
                  label: '+ Novo Autor',
                  onPressed: _showCreateAuthorModal,
                  variant: KasyButtonVariant.secondary,
                ),
              ],
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
              isLoading: _isUploading,
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
