import 'package:cowboydodartinc/components/kasy_avatar_presets.dart';
import 'package:flutter/widgets.dart';

/// Declares what the desktop application bar ([KasyAppBar.application]) shows for
/// a given screen.
///
/// The shell (`WebContentWrapper`) renders one application bar above all content
/// and seeds it with an app-wide default. A screen overrides that default by
/// wrapping its body in a [KasyAppBarConfigurator] (or, for screens built on
/// `KasyOverlayScaffold`, by passing `applicationBar:`). So each screen decides
/// its own desktop chrome — search here, just notifications there — instead of
/// every screen sharing one fixed bar.
///
/// Each element has a `showX` flag (presets toggle these) plus the data/callbacks
/// it needs when shown. A bare [KasyAppBarConfig] mirrors the app default.
@immutable
class KasyAppBarConfig {
  // Search ------------------------------------------------------------------
  final bool showSearch;
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  // Theme toggle ------------------------------------------------------------
  final bool showThemeToggle;
  final VoidCallback? onToggleTheme;

  // Notifications -----------------------------------------------------------
  final bool showNotifications;

  /// Custom notifications control (e.g. a data-aware bell). Replaces the built-in
  /// bell when set and [showNotifications] is true.
  final Widget? notifications;
  final VoidCallback? onNotifications;
  final bool showNotificationBadge;

  // Create ------------------------------------------------------------------
  final bool showCreate;
  final String createLabel;
  final VoidCallback? onCreate;

  // Profile -----------------------------------------------------------------
  final bool showAvatar;
  final Widget? avatar;
  final KasyAvatarGradientData? avatarGradient;
  final VoidCallback? onAvatarTap;

  /// Full control: every element shown by default (matches the app shell). Set a
  /// `showX` to false to drop that element, or pass data/callbacks to wire it.
  const KasyAppBarConfig({
    this.showSearch = true,
    this.searchController,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.showThemeToggle = true,
    this.onToggleTheme,
    this.showNotifications = true,
    this.notifications,
    this.onNotifications,
    this.showNotificationBadge = false,
    this.showCreate = true,
    this.createLabel = 'Create',
    this.onCreate,
    this.showAvatar = true,
    this.avatar,
    this.avatarGradient,
    this.onAvatarTap,
  });

  /// Preset: only the theme toggle — the quietest bar (settings-style screens).
  const KasyAppBarConfig.minimal({VoidCallback? onToggleTheme})
      : this(
          showSearch: false,
          showThemeToggle: true,
          onToggleTheme: onToggleTheme,
          showNotifications: false,
          showCreate: false,
          showAvatar: false,
        );

  /// Preset: search + theme, no quick-create (browse / list screens).
  const KasyAppBarConfig.search({
    TextEditingController? controller,
    String hint = 'Search...',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onToggleTheme,
  }) : this(
          showSearch: true,
          searchController: controller,
          searchHint: hint,
          onSearchChanged: onChanged,
          onSearchSubmitted: onSubmitted,
          showThemeToggle: true,
          onToggleTheme: onToggleTheme,
          showNotifications: false,
          showCreate: false,
          showAvatar: false,
        );

  /// Show ONLY the listed elements (everything else hidden), keeping each one's
  /// data and callbacks from the shell default — so a screen can say "just the
  /// notifications and theme here" without rebuilding the bell or theme wiring.
  ///
  /// ```dart
  /// configure: (bar) => bar.only(search: true),            // browse screen
  /// configure: (bar) => bar.only(notifications: true, themeToggle: true),
  /// ```
  KasyAppBarConfig only({
    bool search = false,
    bool themeToggle = false,
    bool notifications = false,
    bool create = false,
    bool avatar = false,
  }) {
    return copyWith(
      showSearch: search,
      showThemeToggle: themeToggle,
      showNotifications: notifications,
      showCreate: create,
      showAvatar: avatar,
    );
  }

  /// Copy with selective overrides — handy for adapting the shell default.
  KasyAppBarConfig copyWith({
    bool? showSearch,
    TextEditingController? searchController,
    String? searchHint,
    ValueChanged<String>? onSearchChanged,
    ValueChanged<String>? onSearchSubmitted,
    bool? showThemeToggle,
    VoidCallback? onToggleTheme,
    bool? showNotifications,
    Widget? notifications,
    VoidCallback? onNotifications,
    bool? showNotificationBadge,
    bool? showCreate,
    String? createLabel,
    VoidCallback? onCreate,
    bool? showAvatar,
    Widget? avatar,
    KasyAvatarGradientData? avatarGradient,
    VoidCallback? onAvatarTap,
  }) {
    return KasyAppBarConfig(
      showSearch: showSearch ?? this.showSearch,
      searchController: searchController ?? this.searchController,
      searchHint: searchHint ?? this.searchHint,
      onSearchChanged: onSearchChanged ?? this.onSearchChanged,
      onSearchSubmitted: onSearchSubmitted ?? this.onSearchSubmitted,
      showThemeToggle: showThemeToggle ?? this.showThemeToggle,
      onToggleTheme: onToggleTheme ?? this.onToggleTheme,
      showNotifications: showNotifications ?? this.showNotifications,
      notifications: notifications ?? this.notifications,
      onNotifications: onNotifications ?? this.onNotifications,
      showNotificationBadge: showNotificationBadge ?? this.showNotificationBadge,
      showCreate: showCreate ?? this.showCreate,
      createLabel: createLabel ?? this.createLabel,
      onCreate: onCreate ?? this.onCreate,
      showAvatar: showAvatar ?? this.showAvatar,
      avatar: avatar ?? this.avatar,
      avatarGradient: avatarGradient ?? this.avatarGradient,
      onAvatarTap: onAvatarTap ?? this.onAvatarTap,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KasyAppBarConfig &&
        other.showSearch == showSearch &&
        other.searchController == searchController &&
        other.searchHint == searchHint &&
        other.onSearchChanged == onSearchChanged &&
        other.onSearchSubmitted == onSearchSubmitted &&
        other.showThemeToggle == showThemeToggle &&
        other.onToggleTheme == onToggleTheme &&
        other.showNotifications == showNotifications &&
        other.notifications == notifications &&
        other.onNotifications == onNotifications &&
        other.showNotificationBadge == showNotificationBadge &&
        other.showCreate == showCreate &&
        other.createLabel == createLabel &&
        other.onCreate == onCreate &&
        other.showAvatar == showAvatar &&
        other.avatar == avatar &&
        other.avatarGradient == avatarGradient &&
        other.onAvatarTap == onAvatarTap;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        showSearch,
        searchController,
        searchHint,
        onSearchChanged,
        onSearchSubmitted,
        showThemeToggle,
        onToggleTheme,
        showNotifications,
        notifications,
        onNotifications,
        showNotificationBadge,
        showCreate,
        createLabel,
        onCreate,
        showAvatar,
        avatar,
        avatarGradient,
        onAvatarTap,
      ]);
}
