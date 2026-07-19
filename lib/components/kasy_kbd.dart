import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Modifier shown before the key label in a [KasyKbd]. Mirrors the Figma
/// "Shortcut" property — it controls the iconography/label, not the key itself.
enum KasyKbdShortcut {
  /// macOS Command — ⌘.
  command,

  /// Windows key — rendered as the "Win +" label.
  windows,

  /// Control — ⌃.
  ctrl,

  /// Option / Alt — ⌥.
  option,

  /// Shift — ⇧.
  shift,

  /// A plain key with no modifier glyph.
  key,
}

/// Visual emphasis of a [KasyKbd]. Mirrors the Figma "Variant" property.
enum KasyKbdVariant {
  /// Filled key cap (neutral background) — for primary / interactive contexts
  /// where the shortcut needs stronger visibility. Figma calls this "default".
  filled,

  /// No background — for subtle contexts such as helper text, tooltips, or
  /// documentation.
  light,
}

/// Displays a keyboard shortcut or key combination (HeroUI "Kbd").
///
/// ```dart
/// KasyKbd(keyLabel: 'K')                                   // ⌘ K
/// KasyKbd(keyLabel: 'P', shortcut: KasyKbdShortcut.shift)  // ⇧ P
/// KasyKbd(keyLabel: 'Esc', shortcut: KasyKbdShortcut.key)  // Esc
/// ```
class KasyKbd extends StatelessWidget {
  const KasyKbd({
    super.key,
    required this.keyLabel,
    this.shortcut = KasyKbdShortcut.command,
    this.variant = KasyKbdVariant.filled,
  });

  /// The visible key value (e.g. "K", "Esc", "↵").
  final String keyLabel;

  /// Modifier glyph shown before the key. [KasyKbdShortcut.key] shows none.
  final KasyKbdShortcut shortcut;

  /// Filled (neutral background) or light (no background).
  final KasyKbdVariant variant;

  /// The modifier glyph for [shortcut], or null when there is none.
  String? get _modifier {
    switch (shortcut) {
      case KasyKbdShortcut.command:
        return '⌘';
      case KasyKbdShortcut.windows:
        return 'Win +';
      case KasyKbdShortcut.ctrl:
        return '⌃';
      case KasyKbdShortcut.option:
        return '⌥';
      case KasyKbdShortcut.shift:
        return '⇧';
      case KasyKbdShortcut.key:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    // Body sm medium: Inter Medium 14 / 20, muted — per Figma.
    final TextStyle textStyle =
        (context.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: c.muted,
    );
    final String? modifier = _modifier;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Filled uses the neutral key-cap fill; light is transparent.
        color: variant == KasyKbdVariant.filled ? c.neutral : null,
        // 8px radius — Figma rounded-lg.
        borderRadius: BorderRadius.circular(KasyRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (modifier != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(modifier, style: textStyle),
              ),
              const SizedBox(width: 2),
            ],
            Text(keyLabel, style: textStyle),
          ],
        ),
      ),
    );
  }
}
