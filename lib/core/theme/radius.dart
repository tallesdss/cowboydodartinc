import 'package:flutter/material.dart';

/// Kasy Design System — Border Radius Tokens (HeroUI / Tailwind scale)
///
/// Radius is a system-level variable based on Tailwind's base radius values.
/// The full HeroUI scale is exposed as `rounded*` tokens; the existing semantic
/// names (xs/sm/md/lg/xl/full) are kept for backward compatibility and already
/// land on points of this scale:
///   xs (4) = roundedSm · sm (8) = roundedLg · md (12) = roundedXl
///   lg (16) = rounded2xl · xl (24) = rounded3xl
///
/// Usage: KasyRadius.md → 12.0 · BorderRadius.circular(KasyRadius.md)
class KasyRadius {
  KasyRadius._();

  // --- HeroUI / Tailwind scale (canonical) ---
  static const double roundedNone = 0;
  static const double roundedXs = 2;
  static const double roundedSm = 4;
  static const double roundedMd = 6;
  static const double roundedLg = 8;
  static const double roundedXl = 12;
  static const double rounded2xl = 16;
  static const double rounded2_5xl = 20;
  static const double rounded3xl = 24;
  static const double rounded4xl = 32;
  static const double roundedFull = 9999;

  // --- Semantic names (Figma aliases into the rounded-* scale) ---
  // xs → rounded-sm · sm → rounded-lg · md → rounded-xl
  // lg → rounded-2xl · xl → rounded-3xl · full stays 999 (≠ rounded-full 9999)
  static const double xs = roundedSm;
  static const double sm = roundedLg;
  static const double md = roundedXl;
  static const double lg = rounded2xl;
  static const double xl = rounded3xl;
  static const double full = 999;

  // Convenience BorderRadius getters
  static BorderRadius get xsBorderRadius => BorderRadius.circular(xs);
  static BorderRadius get smBorderRadius => BorderRadius.circular(sm);
  static BorderRadius get mdBorderRadius => BorderRadius.circular(md);
  static BorderRadius get lgBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get fullBorderRadius => BorderRadius.circular(full);
}
