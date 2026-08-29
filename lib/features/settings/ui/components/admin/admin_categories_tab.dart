import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_dialog.dart';
import 'package:cowboydodartinc/components/kasy_empty_state.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/components/kasy_toast.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Map<String, IconData> _categoryIcons = {
  'folder': KasyIcons.folder,
  'book': KasyIcons.book,
  'code': KasyIcons.widgets,
  'design': KasyIcons.edit,
  'trendingUp': KasyIcons.analytics,
  'users': KasyIcons.users,
  'dashboard': KasyIcons.dashboard,
  'flag': KasyIcons.flag,
};

const List<String> _categoryColors = [
  'primary',
  'success',
  'warning',
  'danger',
];

Color _resolveColor(BuildContext context, String colorName) {
  return switch (colorName) {
    'success' => context.colors.success,
    'warning' => context.colors.warning,
    'danger' => context.colors.error,
    _ => context.colors.primary,
  };
}

class AdminCategoriesTab extends ConsumerWidget {
  const AdminCategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final c = t.admin_console.categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: context.kasyTextTheme.pageTitle),
                        const SizedBox(height: 4),
                        Text(
                          c.subtitle,
                          style: context.kasyTextTheme.bodyMedium.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  KasyButton(
                    label: c.add,
                    icon: KasyIcons.add,
                    size: KasyButtonSize.small,
                    onPressed: () => _showCategoryEditor(context, ref, null),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (categories.isEmpty)
                KasyEmptyState(
                  icon: KasyIcons.folder,
                  title: c.empty,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final catColor = _resolveColor(context, cat.color);
                    final catIcon = _categoryIcons[cat.icon] ?? KasyIcons.folder;

                    return KasyCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(KasyRadius.md),
                            ),
                            child: Icon(catIcon, color: catColor),
                          ),
                          const SizedBox(width: 16),
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
                          const SizedBox(width: 16),
                          KasyButton.iconOnly(
                            icon: KasyIcons.edit,
                            variant: KasyButtonVariant.ghost,
                            size: KasyButtonSize.small,
                            onPressed: () => _showCategoryEditor(context, ref, cat),
                            semanticLabel: c.edit,
                          ),
                          const SizedBox(width: 8),
                          KasyButton.iconOnly(
                            icon: Icons.delete_outline,
                            variant: KasyButtonVariant.ghost,
                            size: KasyButtonSize.small,
                            onPressed: () => _confirmDelete(context, ref, cat),
                            semanticLabel: c.delete,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, LibraryCategory cat) {
    showKasyConfirmDialog(
      context,
      title: t.admin_console.categories.delete,
      message: t.admin_console.categories.delete_confirm,
      confirmLabel: t.admin_console.categories.delete,
      cancelLabel: t.admin_console.categories.cancel,
      onConfirm: () {
        ref.read(categoriesProvider.notifier).deleteCategory(cat.id);
        showKasyToast(
          context,
          title: t.admin_console.categories.success_deleted,
          tone: KasyToastTone.success,
        );
      },
    );
  }

  void _showCategoryEditor(BuildContext context, WidgetRef ref, LibraryCategory? cat) {
    final isDesktop = MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
    if (isDesktop) {
      showKasyBlurDialog(
        context: context,
        builder: (ctx) => _CategoryEditorForm(
          category: cat,
          onSave: (name, desc, icon, color) {
            _saveCategory(ref, cat, name, desc, icon, color);
            Navigator.of(ctx).pop();
            showKasyToast(
              context,
              title: t.admin_console.categories.success_saved,
              tone: KasyToastTone.success,
            );
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      );
    } else {
      showKasyBottomSheet(
        context: context,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _CategoryEditorForm(
            category: cat,
            onSave: (name, desc, icon, color) {
              _saveCategory(ref, cat, name, desc, icon, color);
              Navigator.of(ctx).pop();
              showKasyToast(
                context,
                title: t.admin_console.categories.success_saved,
                tone: KasyToastTone.success,
              );
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        ),
      );
    }
  }

  void _saveCategory(
    WidgetRef ref,
    LibraryCategory? cat,
    String name,
    String desc,
    String icon,
    String color,
  ) {
    if (cat == null) {
      ref.read(categoriesProvider.notifier).addCategory(
            name: name,
            description: desc,
            icon: icon,
            color: color,
          );
    } else {
      final updated = cat.copyWith(
        name: name,
        description: desc,
        icon: icon,
        color: color,
      );
      ref.read(categoriesProvider.notifier).updateCategory(updated);
    }
  }
}

class _CategoryEditorForm extends StatefulWidget {
  final LibraryCategory? category;
  final void Function(String name, String desc, String icon, String color) onSave;
  final VoidCallback onCancel;

  const _CategoryEditorForm({
    this.category,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_CategoryEditorForm> createState() => _CategoryEditorFormState();
}

class _CategoryEditorFormState extends State<_CategoryEditorForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _selectedIcon = 'folder';
  String _selectedColor = 'primary';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _descCtrl = TextEditingController(text: widget.category?.description ?? '');
    if (widget.category != null) {
      if (widget.category!.icon.isNotEmpty) _selectedIcon = widget.category!.icon;
      if (widget.category!.color.isNotEmpty) _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty || desc.isEmpty) {
      showKasyToast(
        context,
        title: t.admin_console.categories.error_empty_fields,
        tone: KasyToastTone.warning,
      );
      return;
    }
    widget.onSave(name, desc, _selectedIcon, _selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
    final c = t.admin_console.categories;

    return Container(
      width: isDesktop ? 480 : double.infinity,
      padding: EdgeInsets.all(isDesktop ? KasySpacing.xl : KasySpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.category == null ? c.add : c.edit,
            style: context.kasyTextTheme.sectionTitle,
          ),
          const SizedBox(height: KasySpacing.xl),
          KasyTextField(
            controller: _nameCtrl,
            label: c.name,
            variant: KasyTextFieldVariant.flat,
          ),
          const SizedBox(height: KasySpacing.lg),
          KasyTextField(
            controller: _descCtrl,
            label: c.description,
            variant: KasyTextFieldVariant.flat,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: KasySpacing.lg),
          Text(c.icon, style: context.kasyTextTheme.labelLarge),
          const SizedBox(height: KasySpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryIcons.entries.map((e) {
              final isSelected = _selectedIcon == e.key;
              final col = isSelected ? context.colors.primary : context.colors.muted;
              return KasyHover(
                onTap: () => setState(() => _selectedIcon = e.key),
                borderRadius: BorderRadius.circular(KasyRadius.sm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? context.colors.primary : context.colors.border,
                    ),
                    borderRadius: BorderRadius.circular(KasyRadius.sm),
                  ),
                  child: Icon(e.value, color: col, size: 20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: KasySpacing.lg),
          Text(c.color, style: context.kasyTextTheme.labelLarge),
          const SizedBox(height: KasySpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryColors.map((colorName) {
              final isSelected = _selectedColor == colorName;
              final col = _resolveColor(context, colorName);
              return KasyHover(
                onTap: () => setState(() => _selectedColor = colorName),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: col,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: context.colors.onSurface, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: KasySpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              KasyButton(
                label: c.cancel,
                variant: KasyButtonVariant.ghost,
                onPressed: widget.onCancel,
              ),
              const SizedBox(width: KasySpacing.md),
              KasyButton(
                label: c.save,
                onPressed: _handleSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
