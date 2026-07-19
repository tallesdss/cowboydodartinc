import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/ai_chat/providers/ai_conversations_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_avatars.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_conversation_view.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_conversation_list.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Support / AI chat screen with conversation history.
///
/// Responsive:
/// - phones (small): single pane. The conversation list is shown until a
///   conversation is opened; opening one swaps to the thread (back returns).
/// - tablet/desktop (medium+): two panes — the list beside a full-height
///   container that hosts the active thread (or a placeholder when none).
class AiChatPage extends StatelessWidget {
  /// When true the page renders as a root bottom-tab (theme toggle, no back).
  final bool isRootTab;

  const AiChatPage({super.key, this.isRootTab = false});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      small: _MobileLayout(isRootTab: isRootTab),
      medium: const _WideLayout(),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.isRootTab});

  final bool isRootTab;

  @override
  Widget build(BuildContext context) {
    // Phones show only the conversation list; opening a conversation pushes a
    // full-screen route (so the bottom nav bar is hidden for the composer).
    return Scaffold(
      backgroundColor: aiChatCanvasColor(context),
      body: Column(
        children: [
          ColoredBox(
            color: context.colors.surface,
            child: KasyAppBar(
              title: t.ai_chat.title,
              style: isRootTab
                  ? KasyAppBarStyle.rootTab
                  : KasyAppBarStyle.subpage,
              onThemeToggle: isRootTab
                  ? () {
                      KasyHaptics.light(context);
                      ThemeProvider.of(context).toggle();
                    }
                  : null,
            ),
          ),
          const Expanded(
            child: AiConversationList(swipeToDelete: true, isPhone: true),
          ),
        ],
      ),
    );
  }
}

class _WideLayout extends ConsumerWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedConversationIdProvider);

    return Scaffold(
      backgroundColor: aiChatCanvasColor(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            // Vertical hairline matching the sidebar/web-header line.
            decoration: BoxDecoration(
              color: aiChatCanvasColor(context),
              border: Border(
                right: BorderSide(color: context.colors.border, width: 0.5),
              ),
            ),
            child: const SizedBox(
              width: 340,
              child: AiConversationList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(KasySpacing.md),
              child: _DetailContainer(
                child: selectedId == null
                    ? const _DetailPlaceholder()
                    : const AiChatConversationView(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded, full-height surface that hosts the active thread (it scrolls
/// internally). Mirrors the Figma reading-pane container.
class _DetailContainer extends StatelessWidget {
  const _DetailContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      borderRadius: BorderRadius.circular(KasyRadius.xl),
      child: child,
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KasySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiChatAssistantAvatar(diameter: kAiChatEmptyAvatarDiameter),
            const SizedBox(height: KasySpacing.md),
            Text(
              t.home.cards.assistant_title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: KasySpacing.xs),
            Text(
              t.ai_chat.no_conversation_selected,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
