import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_conversation_entity.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_avatars.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// A single row in the conversation list (Figma `mail` list item): avatar +
/// title + last-message preview + timestamp. Avatar/title reflect the author
/// of the most recent message — assistant (app identity) or the user.
class AiConversationTile extends ConsumerStatefulWidget {
  const AiConversationTile({
    super.key,
    required this.conversation,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final AiChatConversationEntity conversation;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  ConsumerState<AiConversationTile> createState() => _AiConversationTileState();
}

class _AiConversationTileState extends ConsumerState<AiConversationTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final bool fromUser = conversation.lastMessageRole == 'user';

    final String title = fromUser
        ? _userDisplayName(ref) ?? t.ai_chat.title
        : t.ai_chat.title;
    final Widget avatar = fromUser
        ? const AiChatUserAvatar(diameter: 36)
        : const AiChatAssistantAvatar(diameter: 36);
    final String preview =
        conversation.lastMessageContent ?? t.ai_chat.conversations_empty;

    final Color titleColor = context.colors.onBackground;
    final Color subtitleColor = context.colors.muted;

    final Widget tile = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      decoration: BoxDecoration(
        color: widget.selected
            ? context.colors.primarySoft
            : (_hovered ? context.colors.surfaceNeutralSoft : null),
        borderRadius: BorderRadius.circular(KasyRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar,
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.kasyTextTheme.listRowTitle.copyWith(
                          color: titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    _trailing(context, subtitleColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget tappable = Semantics(
      button: true,
      selected: widget.selected,
      label: title,
      child: KasyFocusRing(
        onActivate: widget.onTap,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: tile,
        ),
      ),
    );

    // Hover reveals the delete affordance on pointer devices (web / desktop).
    if (!kIsWeb) return tappable;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: tappable,
    );
  }

  /// On hover (desktop), shows a delete button; otherwise the timestamp.
  Widget _trailing(BuildContext context, Color color) {
    if (kIsWeb && _hovered) {
      return SizedBox(
        height: 16,
        // Plain pointer-cursor tap (no Material ripple), consistent with the
        // rest of the kit's web controls. The icon only appears while the row
        // is hovered, so it's already a pointer-only affordance.
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDelete,
            child: Icon(
              KasyIcons.trash,
              size: KasyIconSize.sm,
              color: context.colors.error,
            ),
          ),
        ),
      );
    }
    return Text(
      _formatTimestamp(context, widget.conversation.updatedAt),
      style: context.textTheme.bodySmall?.copyWith(color: color),
    );
  }

  String? _userDisplayName(WidgetRef ref) {
    final user = ref.watch(userStateNotifierProvider).user;
    if (user is! AuthenticatedUserData) return null;
    final String? name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final String local = user.email.split('@').first.trim();
    return local.isNotEmpty ? local : null;
  }

  String _formatTimestamp(BuildContext context, DateTime time) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    final bool sameDay =
        now.year == time.year && now.month == time.month && now.day == time.day;
    if (sameDay) {
      return DateFormat.jm(locale).format(time);
    }
    if (now.year == time.year) {
      return DateFormat.MMMd(locale).format(time);
    }
    return DateFormat.yMd(locale).format(time);
  }
}

/// Skeleton row mirroring [AiConversationTile] (avatar + title + preview).
class AiConversationSkeletonTile extends StatelessWidget {
  const AiConversationSkeletonTile({super.key, this.index = 0});

  final int index;

  static const List<double> _previewWidths = [180, 150, 200, 130];

  @override
  Widget build(BuildContext context) {
    final double previewW = _previewWidths[index % _previewWidths.length];

    return KasySkeletonGroup(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KasySkeleton.circle(size: 36),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: KasySkeleton(width: 120, height: 13)),
                      SizedBox(width: KasySpacing.xs),
                      KasySkeleton(width: 36, height: 10),
                    ],
                  ),
                  const SizedBox(height: 2),
                  KasySkeleton(width: previewW, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
