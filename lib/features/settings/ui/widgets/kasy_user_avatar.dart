import 'package:cowboydodartinc/components/kasy_avatar.dart';
import 'package:cowboydodartinc/components/kasy_avatar_presets.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/avatar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in user's avatar, resolved through the exact same path as the
/// settings screen — so it behaves identically across the **Firebase, Supabase
/// and API** backends. [avatar_utils] (the URL resolver) is swapped per backend
/// by the CLI, and the user identity comes from [userStateNotifierProvider]
/// (backend-agnostic), so this widget never references a specific backend.
///
/// Resolution order: the user's `avatarPath` URL → the in-memory cache →
/// the backend's avatar store (async). Falls back to a [gradient] fill while
/// loading, for guests, or when no photo exists.
class KasyUserAvatar extends ConsumerWidget {
  const KasyUserAvatar({
    super.key,
    this.diameter = 36,
    this.gradient = KasyAvatarGradients.indigo,
    this.onTap,
  });

  /// Avatar diameter in logical pixels.
  final double diameter;

  /// Gradient shown when the user has no photo (or while it loads).
  final KasyAvatarGradientData gradient;

  /// Tap handler (open account menu / profile). Null = inert.
  final VoidCallback? onTap;

  KasyAvatar _avatar([ImageProvider? image]) => KasyAvatar(
    diameter: diameter,
    image: image,
    backgroundGradient: gradient,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User user = ref.watch(userStateNotifierProvider).user;

    // 1. A direct URL on the user record (social logins; Supabase/API users).
    final String? avatarPath = switch (user) {
      AuthenticatedUserData(:final avatarPath) => avatarPath,
      _ => null,
    };
    if (avatarPath != null && avatarPath.isNotEmpty) {
      return _avatar(NetworkImage(avatarPath));
    }

    final String? userId = user.idOrNull;
    if (userId != null) {
      // 2. Cached URL — synchronous, avoids a fallback flash.
      final String? cached = getCachedAvatarUrl(userId);
      if (cached != null && cached.isNotEmpty) {
        return _avatar(NetworkImage(cached));
      }
      // 3. Resolve through the backend's avatar store (async, per-backend).
      return FutureBuilder<String>(
        future: resolveAvatarUrl(userId),
        builder: (context, snapshot) {
          final String? url = snapshot.data;
          return _avatar(
            (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
          );
        },
      );
    }

    // 4. Guest / loading → gradient fill.
    return _avatar();
  }
}
