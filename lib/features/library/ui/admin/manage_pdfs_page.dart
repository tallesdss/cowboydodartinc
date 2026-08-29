import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/library_firebase_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:file_picker/file_picker.dart';
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
  final _tagsController = TextEditingController();

  final List<String> _selectedCategoryIds = [];

  // Real Upload Fields
  String? _selectedFilePath;
  String? _selectedFileName;
  double? _selectedFileSize;
  
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _savePdf() async {
    if (_selectedFilePath == null) {
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

    setState(() => _isUploading = true);

    try {
      final userId = ref.read(userStateNotifierProvider).user.idOrNull ?? 'unknown';
      final repo = ref.read(libraryFirebaseRepositoryProvider);
      
      final downloadUrl = await repo.uploadPdfFile(_selectedFilePath!, _selectedFileName!);

      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await ref.read(pdfsProvider.notifier).addPdf(
        title: _titleController.text,
        description: _descController.text,
        categoryIds: _selectedCategoryIds,
        author: _authorController.text,
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
      withData: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      setState(() {
        _selectedFilePath = file.path;
        _selectedFileName = file.name;
        _selectedFileSize = (file.size / (1024 * 1024)); // MB

        // Auto-fill some fields to help the user
        _titleController.text = _selectedFileName!
            .replaceAll('.pdf', '')
            .replaceAll('_', ' ');
        if (_authorController.text.isEmpty) {
          _authorController.text =
              ref.read(userStateNotifierProvider).user.isAdmin
                  ? 'Admin / Dev'
                  : 'Cliente';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final userState = ref.watch(userStateNotifierProvider).user;
    final isAdmin = userState.isAdmin;

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
            KasyTextField(
              controller: _authorController,
              label: t.library.pdf_author,
              validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
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
