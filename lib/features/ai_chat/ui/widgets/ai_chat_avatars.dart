import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/avatar_utils.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Diameter used beside chat bubbles.
const double kAiChatAvatarDiameter = 32;

/// Diameter shown in the empty state hero.
const double kAiChatEmptyAvatarDiameter = 64;

/// Filled launcher icon for assistant identity (chat list, bubbles, empty
/// hero). Same asset in light and dark. Auth / Home / sidebar keep the
/// transparent wordmark via [KasyBrandLogo] (`logo-light` / `logo-dark`).
const String kAiChatAppIconAsset = 'assets/branding/app-icon.png';

/// Soft canvas behind the AI chat list and thread.
///
/// Light stays on the kit [KasyColors.background] (neutral). Dark uses
/// [KasyColors.backgroundSecondary] for gentle contrast against the app bar.
Color aiChatCanvasColor(BuildContext context) {
  final colors = context.colors;
  return context.isDark ? colors.backgroundSecondary : colors.background;
}

/// Project / assistant avatar: filled `app-icon.png` only.
///
/// Paints the asset directly (no theme swap, no soft primary disc, no
/// [ColorFiltered]). A prior path used [KasyBrandLogo], which swapped to
/// white `logo-dark` in dark mode and looked like a different mark.
class AiChatAssistantAvatar extends StatelessWidget {
  const AiChatAssistantAvatar({
    super.key,
    this.diameter = kAiChatAvatarDiameter,
  });

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: t.home.cards.assistant_title,
      child: ClipOval(
        child: Image.asset(
          kAiChatAppIconAsset,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// User avatar resolved from profile photo, initials, or [KasyAvatar] fallback.
class AiChatUserAvatar extends ConsumerWidget {
  const AiChatUserAvatar({
    super.key,
    this.diameter = kAiChatAvatarDiameter,
    this.showShadow = false,
  });

  final double diameter;
  final bool showShadow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateNotifierProvider).user;
    return switch (user) {
      AuthenticatedUserData(
        :final id,
        :final name,
        :final email,
        :final avatarPath,
      ) =>
        _AiChatUserAvatarContent(
          diameter: diameter,
          userId: id,
          avatarPath: avatarPath,
          initials: _initialsFrom(name, email),
          showShadow: showShadow,
        ),
      _ => KasyAvatar(
        diameter: diameter,
        icon: KasyIcons.person,
        fallbackSurface: KasyAvatarFallbackSurface.soft,
        tone: KasyAvatarTone.neutral,
        showShadow: showShadow,
      ),
    };
  }

  String? _initialsFrom(String? name, String email) {
    final String? trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }
    final String local = email.split('@').first.trim();
    if (local.isNotEmpty) {
      return local;
    }
    return null;
  }
}

class _AiChatUserAvatarContent extends StatelessWidget {
  const _AiChatUserAvatarContent({
    required this.diameter,
    required this.userId,
    required this.avatarPath,
    required this.initials,
    required this.showShadow,
  });

  final double diameter;
  final String? userId;
  final String? avatarPath;
  final String? initials;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final String? path = avatarPath;
    if (path != null && path.isNotEmpty) {
      return _buildAvatar(image: NetworkImage(path));
    }

    final String? id = userId;
    if (id != null) {
      final String? cachedUrl = getCachedAvatarUrl(id);
      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        return _buildAvatar(image: NetworkImage(cachedUrl));
      }

      return FutureBuilder<String>(
        future: resolveAvatarUrl(id),
        builder: (context, snapshot) {
          final String? url = snapshot.data;
          return _buildAvatar(
            image: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
          );
        },
      );
    }

    return _buildAvatar();
  }

  KasyAvatar _buildAvatar({ImageProvider? image}) {
    return KasyAvatar(
      diameter: diameter,
      image: image,
      initials: initials,
      icon: KasyIcons.person,
      fallbackSurface: KasyAvatarFallbackSurface.soft,
      tone: KasyAvatarTone.neutral,
      showShadow: showShadow,
    );
  }
}
