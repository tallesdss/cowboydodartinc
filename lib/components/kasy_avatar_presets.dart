import 'package:flutter/material.dart';

/// Gradient data for [KasyAvatar] orb-style fills.
///
/// Holds the four colors needed to render the background wash and the
/// soft-focus sphere: [bgTop]/[bgBottom] for the canvas gradient, and
/// [orbTop]/[orbBottom] for the blurred orb overlay.
///
/// Matches the HeroUI Figma Kit V3 "Image Use" avatar palette exactly.
@immutable
class KasyAvatarGradientData {
  final Color bgTop;
  final Color bgBottom;
  final Color orbTop;
  final Color orbBottom;

  const KasyAvatarGradientData({
    required this.bgTop,
    required this.bgBottom,
    required this.orbTop,
    required this.orbBottom,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KasyAvatarGradientData &&
        other.bgTop == bgTop &&
        other.bgBottom == bgBottom &&
        other.orbTop == orbTop &&
        other.orbBottom == orbBottom;
  }

  @override
  int get hashCode => Object.hash(bgTop, bgBottom, orbTop, orbBottom);
}

/// All 14 orb-style avatar gradient presets (matches Figma "Image Use" section).
abstract final class KasyAvatarGradients {
  /// Cornflower-blue canvas, deep-blue orb.
  static const KasyAvatarGradientData blueDark = KasyAvatarGradientData(
    bgTop: Color(0xFFE9E9FF),
    bgBottom: Color(0xFFCCCDF1),
    orbTop: Color(0xFF5D9BE7),
    orbBottom: Color(0xFF0026FF),
  );

  /// Ice-blue canvas, cyan-to-violet orb.
  static const KasyAvatarGradientData blue = KasyAvatarGradientData(
    bgTop: Color(0xFFE9E9FF),
    bgBottom: Color(0xFFCCE5F1),
    orbTop: Color(0xFF5DD0E7),
    orbBottom: Color(0xFF7300FF),
  );

  /// Pale-aqua canvas, aqua-to-deep-blue orb.
  static const KasyAvatarGradientData sky = KasyAvatarGradientData(
    bgTop: Color(0xFFE9FAFF),
    bgBottom: Color(0xFFCCECF1),
    orbTop: Color(0xFF5DE7E7),
    orbBottom: Color(0xFF001AFF),
  );

  /// Mint canvas, seafoam-to-forest orb.
  static const KasyAvatarGradientData emerald = KasyAvatarGradientData(
    bgTop: Color(0xFFE9FFF0),
    bgBottom: Color(0xFFCCF1D6),
    orbTop: Color(0xFF52DEB0),
    orbBottom: Color(0xFF0D5C45),
  );

  /// Pale-green canvas, mint-to-royal-blue orb.
  static const KasyAvatarGradientData green = KasyAvatarGradientData(
    bgTop: Color(0xFFE9FFEB),
    bgBottom: Color(0xFFD3F1CC),
    orbTop: Color(0xFF5DE79D),
    orbBottom: Color(0xFF0033FF),
  );

  /// Sage canvas, turquoise-to-deep-forest orb.
  static const KasyAvatarGradientData forest = KasyAvatarGradientData(
    bgTop: Color(0xFFCDE8D5),
    bgBottom: Color(0xFF9CD0AA),
    orbTop: Color(0xFF5DD9AF),
    orbBottom: Color(0xFF094E39),
  );

  /// Cream canvas, gold-to-deep-red orb.
  static const KasyAvatarGradientData orange = KasyAvatarGradientData(
    bgTop: Color(0xFFFFF8E9),
    bgBottom: Color(0xFFF1DFCC),
    orbTop: Color(0xFFE7BD5D),
    orbBottom: Color(0xFFFF1E00),
  );

  /// Blush canvas, salmon-to-scarlet orb.
  static const KasyAvatarGradientData red = KasyAvatarGradientData(
    bgTop: Color(0xFFFFE9E9),
    bgBottom: Color(0xFFF1CCCC),
    orbTop: Color(0xFFE7885D),
    orbBottom: Color(0xFFFF0004),
  );

  /// Lavender canvas, soft-purple-to-cobalt orb.
  static const KasyAvatarGradientData indigo = KasyAvatarGradientData(
    bgTop: Color(0xFFEDCEFF),
    bgBottom: Color(0xFFF1CCEE),
    orbTop: Color(0xFFB45DE7),
    orbBottom: Color(0xFF0055FF),
  );

  /// Lilac canvas, medium-purple-to-crimson orb.
  static const KasyAvatarGradientData purple = KasyAvatarGradientData(
    bgTop: Color(0xFFEFE9FF),
    bgBottom: Color(0xFFDBCCF1),
    orbTop: Color(0xFF8D5DE7),
    orbBottom: Color(0xFFFF0009),
  );

  /// Pink-white canvas, orchid-to-magenta orb.
  static const KasyAvatarGradientData rose = KasyAvatarGradientData(
    bgTop: Color(0xFFFFE9FB),
    bgBottom: Color(0xFFF0CCF1),
    orbTop: Color(0xFFE75DCB),
    orbBottom: Color(0xFFFF000D),
  );

  /// Blush canvas, hot-pink-to-coral orb.
  static const KasyAvatarGradientData hotPink = KasyAvatarGradientData(
    bgTop: Color(0xFFFFE9E9),
    bgBottom: Color(0xFFF1CCCD),
    orbTop: Color(0xFFE43673),
    orbBottom: Color(0xFFFB5059),
  );

  /// Light-grey canvas, silver-to-near-black orb.
  static const KasyAvatarGradientData silver = KasyAvatarGradientData(
    bgTop: Color(0xFFE3E3E3),
    bgBottom: Color(0xFFC6C6C6),
    orbTop: Color(0xFF949494),
    orbBottom: Color(0xFF080808),
  );

  /// Dark-grey canvas, mid-grey-to-very-dark orb.
  static const KasyAvatarGradientData black = KasyAvatarGradientData(
    bgTop: Color(0xFF252525),
    bgBottom: Color(0xFF444444),
    orbTop: Color(0xFF7F7F7F),
    orbBottom: Color(0xFF1F1F1F),
  );

  /// All 14 presets in display order (matches Figma "Image Use" section).
  static const List<KasyAvatarGradientData> all = [
    blueDark, blue, sky, emerald, green, forest,
    orange, red, indigo, purple, rose, hotPink,
    silver, black,
  ];
}

/// Fixed Unsplash URLs for demos/catalog (network + permissions in prod).
abstract final class KasyAvatarDemoPhotos {
  static const String manGlasses =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&auto=format';
  static const String womanSmile =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop&auto=format';
  static const String womanCurly =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&auto=format';
  static const String manBeard =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&auto=format';
}
