import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_conversation_entity.dart';
import 'package:cowboydodartinc/features/ai_chat/providers/ai_conversations_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_conversation_view.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_conversation_tile.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The conversation list pane (Figma `mail` list). Creating a new conversation
/// has a single entry point per layout to avoid duplication:
/// - wide: a round "+" button in the header (the app bar / web header own the
///   top chrome elsewhere, so the title lives here).
/// - phone: a full-width button pinned at the bottom (Figma "New Email"); the
///   title is shown by the page app bar, so there is no header here.
///
/// Selecting a tile updates [selectedConversationIdProvider]; the parent shell
/// reacts (open the thread on phones, swap the detail pane on wide layouts).
class AiConversationList extends ConsumerWidget {
  const AiConversationList({
    super.key,
    this.swipeToDelete = false,
    this.isPhone = false,
  });

  /// When true (phones), each row can be swiped to reveal a delete action and
  /// the create action becomes a pinned bottom button instead of a header orb.
  final bool swipeToDelete;
  final bool isPhone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(aiConversationsNotifierProvider);
    final selectedId = ref.watch(selectedConversationIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isPhone) _Header(onCreate: () => _createConversation(context, ref)),
        Expanded(
          child: conversationsAsync.when(
            loading: () => KasySkeletonGroup(
              child: ScrollConfiguration(
                behavior: const KasyKitScrollBehavior(),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.smd,
                    KasySpacing.smd,
                    KasySpacing.smd,
                    KasySpacing.md,
                  ),
                  itemCount: 7,
                  separatorBuilder: (_, _) => isPhone
                      ? Divider(
                          height: KasySpacing.xs,
                          thickness: 0.5,
                          color: context.colors.border,
                        )
                      : const SizedBox(height: KasySpacing.xs),
                  itemBuilder: (context, index) =>
                      AiConversationSkeletonTile(index: index),
                ),
              ),
            ),
            error: (_, _) => Center(child: Text(t.ai_chat.error_network)),
            data: (conversations) {
              if (conversations.isEmpty) return const _EmptyConversations();
              return ScrollConfiguration(
                behavior: const KasyKitScrollBehavior(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.smd,
                    KasySpacing.smd,
                    KasySpacing.smd,
                    KasySpacing.md,
                  ),
                  itemCount: conversations.length,
                  separatorBuilder: (_, _) => isPhone
                      // Horizontal hairline between rows (sidebar/header line).
                      ? Divider(
                          height: KasySpacing.xs,
                          thickness: 0.5,
                          color: context.colors.border,
                        )
                      : const SizedBox(height: KasySpacing.xs),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildRow(
                      context,
                      ref,
                      conversation,
                      selected: conversation.id == selectedId,
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (isPhone) _BottomCreateButton(onCreate: () => _createConversation(context, ref)),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    AiChatConversationEntity conversation, {
    required bool selected,
  }) {
    final tile = AiConversationTile(
      conversation: conversation,
      selected: selected,
      onTap: () {
        KasyHaptics.light(context);
        _open(context, ref, conversation.id);
      },
      onDelete: () => _confirmDelete(context, ref, conversation),
    );

    if (!swipeToDelete) return tile;

    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: _swipeDeleteBackground(context),
      confirmDismiss: (_) async {
        final bool confirmed = await _askDelete(context);
        if (confirmed) {
          await ref
              .read(aiConversationsNotifierProvider.notifier)
              .delete(conversation.id);
        }
        // The list rebuilds from provider state after delete, so we never let
        // Dismissible remove the row itself (avoids a stale-widget assertion).
        return false;
      },
      child: tile,
    );
  }

  Widget _swipeDeleteBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceErrorSoft,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
      ),
      child: Icon(KasyIcons.trash, color: context.colors.error),
    );
  }

  /// Selects a conversation; on phones it also pushes the full-screen thread
  /// (a root-navigator route, so the bottom nav bar is hidden).
  void _open(BuildContext context, WidgetRef ref, String conversationId) {
    ref.read(selectedConversationIdProvider.notifier).state = conversationId;
    if (isPhone) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const AiChatConversationPage()),
      );
    }
  }

  Future<void> _createConversation(BuildContext context, WidgetRef ref) async {
    KasyHaptics.light(context);
    final id = await ref.read(aiConversationsNotifierProvider.notifier).create();
    if (id != null && context.mounted) {
      _open(context, ref, id);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AiChatConversationEntity conversation,
  ) async {
    final bool confirmed = await _askDelete(context);
    if (confirmed) {
      await ref
          .read(aiConversationsNotifierProvider.notifier)
          .delete(conversation.id);
    }
  }

  Future<bool> _askDelete(BuildContext context) async {
    bool confirmed = false;
    await showKasyConfirmDialog(
      context,
      title: t.ai_chat.delete_title,
      message: t.ai_chat.delete_message,
      cancelLabel: t.ai_chat.delete_cancel,
      confirmLabel: t.ai_chat.delete_confirm,
      destructive: true,
      onConfirm: () => confirmed = true,
    );
    return confirmed;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Horizontal hairline matching the sidebar/web-header bottom border.
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KasySpacing.lg,
          KasySpacing.md,
          KasySpacing.smd,
          KasySpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                t.ai_chat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.pageTitle.copyWith(
                  color: context.colors.onBackground,
                ),
              ),
            ),
            KasyButton.iconOnly(
              icon: KasyIcons.add,
              onPressed: onCreate,
              size: KasyButtonSize.small,
              iconOnlyLayoutExtent: 36,
              iconGlyphSize: 20,
              semanticLabel: t.ai_chat.new_conversation,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCreateButton extends StatelessWidget {
  const _BottomCreateButton({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Horizontal hairline above the pinned action (matches sidebar footer).
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.md,
            KasySpacing.sm,
            KasySpacing.md,
            KasySpacing.sm,
          ),
          child: KasyButton(
            label: t.ai_chat.new_conversation,
            icon: KasyIcons.add,
            expand: true,
            onPressed: onCreate,
          ),
        ),
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return KasyEmptyState(
      icon: KasyIcons.chat,
      title: t.ai_chat.conversations_empty,
      subtitle: t.ai_chat.conversations_empty_hint,
      padding: const EdgeInsets.all(KasySpacing.lg),
    );
  }
}
