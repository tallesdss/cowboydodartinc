/// Screen transition presets used by [KasyNavigationConfig] and [kasyTransitionPage].
enum KasyTransitionKind {
  /// Crossfade — default push across Android, iOS, and Web.
  fade,

  /// Material fade-through (outgoing fades before incoming).
  fadeThrough,

  /// Shared axis depth / scale (no lateral slide).
  sharedAxisScaled,

  /// Shared axis horizontal slide.
  sharedAxisHorizontal,

  /// Instant swap (camera, technical routes).
  none,
}
