import 'package:cowboydodartinc/components/kasy_description.dart';
import 'package:cowboydodartinc/components/kasy_field_error.dart';
import 'package:cowboydodartinc/components/kasy_label.dart';
import 'package:cowboydodartinc/components/kasy_tag.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// How many tags in a [KasyTagGroup] can be selected at once.
enum KasyTagSelection { none, single, multiple }

/// One tag inside a [KasyTagGroup].
class KasyTagData {
  const KasyTagData(this.label, {this.prefixIcon, this.enabled = true});

  final String label;
  final IconData? prefixIcon;
  final bool enabled;
}

/// Kasy-styled tag group (HeroUI TagGroup) — a labelled, focusable list of
/// [KasyTag]s with optional selection, removal, overflow counter and helper /
/// error text. Composed from the kit's form primitives ([KasyLabel],
/// [KasyDescription], [KasyFieldError]) so it reads like every other field.
class KasyTagGroup extends StatelessWidget {
  const KasyTagGroup({
    super.key,
    required this.tags,
    this.label,
    this.required = false,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.selected = const <int>{},
    this.onSelectionChanged,
    this.onRemove,
    this.variant = KasyTagVariant.neutral,
    this.size = KasyTagSize.md,
    this.selectionMode = KasyTagSelection.multiple,
    this.maxVisible,
  });

  final List<KasyTagData> tags;

  /// Optional field label (rendered via [KasyLabel]).
  final String? label;
  final bool required;

  /// Helper text below the tags; replaced by [errorText] when [isInvalid].
  final String? description;
  final String? errorText;
  final bool isInvalid;

  final Set<int> selected;
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// When set, each tag shows a × that calls this with the tag's index.
  final ValueChanged<int>? onRemove;

  final KasyTagVariant variant;
  final KasyTagSize size;
  final KasyTagSelection selectionMode;

  /// Caps how many tags render; the rest collapse into a "+N" counter tag.
  final int? maxVisible;

  void _toggle(int index) {
    if (onSelectionChanged == null) return;
    final Set<int> next = <int>{...selected};
    switch (selectionMode) {
      case KasyTagSelection.none:
        return;
      case KasyTagSelection.single:
        next
          ..clear()
          ..add(index);
      case KasyTagSelection.multiple:
        if (next.contains(index)) {
          next.remove(index);
        } else {
          next.add(index);
        }
    }
    onSelectionChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final bool selectable = selectionMode != KasyTagSelection.none;
    final int visible = maxVisible == null
        ? tags.length
        : maxVisible!.clamp(0, tags.length);
    final int overflow = tags.length - visible;

    final List<Widget> tagWidgets = <Widget>[
      for (int i = 0; i < visible; i++)
        KasyTag(
          label: tags[i].label,
          prefixIcon: tags[i].prefixIcon,
          variant: variant,
          size: size,
          enabled: tags[i].enabled,
          selected: selected.contains(i),
          onPressed: selectable ? () => _toggle(i) : null,
          onRemove: onRemove == null ? null : () => onRemove!(i),
        ),
      if (overflow > 0)
        KasyTag(label: '+$overflow', variant: variant, size: size),
    ];

    final List<Widget> column = <Widget>[
      if (label != null) ...[
        KasyLabel(label!, required: required, isInvalid: isInvalid),
        // HeroUI: 4px between the label and the tag list.
        const SizedBox(height: KasySpacing.xs),
      ],
      Wrap(
        // HeroUI TagList: 6px between tags (spacing/1.5).
        spacing: 6,
        runSpacing: 6,
        children: tagWidgets,
      ),
      if (isInvalid && errorText != null) ...[
        const SizedBox(height: KasySpacing.xs),
        KasyFieldError(errorText!),
      ] else if (description != null) ...[
        const SizedBox(height: KasySpacing.xs),
        KasyDescription(description!),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: column,
    );
  }
}
