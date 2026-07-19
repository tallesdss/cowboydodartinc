import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/features/ai_chat/providers/ai_chat_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/providers/ai_conversations_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_avatars.dart';
import 'package:cowboydodartinc/features/ai_chat/ui/widgets/ai_chat_composer.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen conversation page used on phones. Pushed on the root navigator
/// so the bottom navigation bar is hidden — the composer needs the bottom edge.
/// Clears the selected conversation when dismissed (back button or system pop).
class AiChatConversationPage extends ConsumerWidget {
  const AiChatConversationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(selectedConversationIdProvider.notifier).state = null;
        }
      },
      child: Scaffold(
        backgroundColor: aiChatCanvasColor(context),
        body: Column(
          children: [
            ColoredBox(
              color: context.colors.surface,
              child: KasyAppBar(
                title: t.ai_chat.title,
                onThemeToggle: () {
                  KasyHaptics.light(context);
                  ThemeProvider.of(context).toggle();
                },
              ),
            ),
            const Expanded(child: AiChatConversationView()),
          ],
        ),
      ),
    );
  }
}

/// The chat thread for the currently selected conversation: message list +
/// composer. Has no chrome of its own — it scrolls *inside* whatever container
/// hosts it (a rounded pane on desktop, a full page below the app bar on phone).
class AiChatConversationView extends ConsumerStatefulWidget {
  const AiChatConversationView({super.key});

  @override
  ConsumerState<AiChatConversationView> createState() =>
      _AiChatConversationViewState();
}

class _AiChatConversationViewState
    extends ConsumerState<AiChatConversationView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom once the history finishes loading.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMessage() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || prompt.length > kAiChatMaxMessageLength) return;
    _controller.clear();
    ref.read(aiChatNotifierProvider.notifier).sendMessage(prompt);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to bottom whenever the message list changes (new chunk / message).
    ref.listen(aiChatNotifierProvider, (_, _) => _scrollToBottom());

    final chatAsync = ref.watch(aiChatNotifierProvider);
    final bool isReplying = chatAsync.maybeWhen(
      data: (s) => s.isReplying,
      orElse: () => false,
    );

    return Column(
      children: [
        Expanded(
          child: chatAsync.when(
            loading: () => _buildLoadingMessages(context),
            error: (_, _) => Center(child: Text(t.ai_chat.error_network)),
            data: (chatState) => _buildMessages(context, chatState),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              KasySpacing.pageHorizontalGutter,
              KasySpacing.sm,
              KasySpacing.pageHorizontalGutter,
              KasySpacing.md,
            ),
            child: AiChatComposer(
              controller: _controller,
              isReplying: isReplying,
              onSend: _sendMessage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMessages(BuildContext context) {
    return KasySkeletonGroup(
      child: ScrollConfiguration(
        behavior: const KasyKitScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.pageHorizontalGutter,
            KasySpacing.md,
            KasySpacing.pageHorizontalGutter,
            KasySpacing.md,
          ),
          children: const [
            _ChatBubbleSkeleton(isUser: false, width: 220),
            _ChatBubbleSkeleton(isUser: true, width: 160),
            _ChatBubbleSkeleton(isUser: false, width: 260),
            _ChatBubbleSkeleton(isUser: true, width: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(BuildContext context, AiChatState chatState) {
    final messages = chatState.messages;
    final isReplying = chatState.isReplying;

    // Show the typing indicator only while waiting for the first SSE chunk.
    // Once streaming starts the partial assistant bubble is already in [messages].
    final showTypingIndicator = isReplying && !chatState.streamingStarted;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty && !isReplying
              ? const _EmptyState()
              : ScrollConfiguration(
                  behavior: const KasyKitScrollBehavior(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      KasySpacing.pageHorizontalGutter,
                      KasySpacing.md,
                      KasySpacing.pageHorizontalGutter,
                      KasySpacing.md,
                    ),
                    // +1 for the typing indicator shown before the first SSE chunk
                    itemCount: messages.length + (showTypingIndicator ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (showTypingIndicator && index == messages.length) {
                        return const _TypingIndicatorRow();
                      }
                      final message = messages[index];
                      return _ChatBubble(
                        message: message,
                        isUser: message.role == 'user',
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.pageHorizontalGutter,
        ),
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
              t.ai_chat.empty_state,
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

/// How much of the available row width a single bubble may occupy. Caps long
/// messages so they don't stretch edge-to-edge on wide layouts (desktop),
/// keeping the left/right chat rhythm like WhatsApp. Short messages still hug
/// their content via [Flexible].
const double _kMaxBubbleWidthFraction = 0.75;

class _ChatBubbleSkeleton extends StatelessWidget {
  const _ChatBubbleSkeleton({required this.isUser, required this.width});

  final bool isUser;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Widget bubble = KasySkeleton(
      width: width,
      height: 44,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(KasyRadius.lg),
        topRight: const Radius.circular(KasyRadius.lg),
        bottomLeft: isUser
            ? const Radius.circular(KasyRadius.lg)
            : const Radius.circular(KasyRadius.xs),
        bottomRight: isUser
            ? const Radius.circular(KasyRadius.xs)
            : const Radius.circular(KasyRadius.lg),
      ),
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KasySpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bubble,
            const SizedBox(width: KasySpacing.xs),
            const KasySkeleton.circle(size: 32),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: KasySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KasySkeleton.circle(size: 32),
          const SizedBox(width: KasySpacing.xs),
          bubble,
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isUser});

  final ChatMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final Widget bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? context.colors.primary
            : context.colors.onBackground.withValues(alpha: 0.06),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(KasyRadius.lg),
          topRight: const Radius.circular(KasyRadius.lg),
          bottomLeft: isUser
              ? const Radius.circular(KasyRadius.lg)
              : const Radius.circular(KasyRadius.xs),
          bottomRight: isUser
              ? const Radius.circular(KasyRadius.xs)
              : const Radius.circular(KasyRadius.lg),
        ),
      ),
      child: Text(
        message.content,
        style: context.textTheme.bodyLarge?.copyWith(
          color: isUser ? context.colors.onPrimary : context.colors.onBackground,
          height: 1.4,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget cappedBubble = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * _kMaxBubbleWidthFraction,
          ),
          child: bubble,
        );

        if (isUser) {
          return Padding(
            padding: const EdgeInsets.only(bottom: KasySpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cappedBubble),
                const SizedBox(width: KasySpacing.xs),
                const AiChatUserAvatar(),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: KasySpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiChatAssistantAvatar(),
              const SizedBox(width: KasySpacing.xs),
              Flexible(child: cappedBubble),
            ],
          ),
        );
      },
    );
  }
}

class _TypingIndicatorRow extends StatelessWidget {
  const _TypingIndicatorRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: KasySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiChatAssistantAvatar(),
          SizedBox(width: KasySpacing.xs),
          _TypingIndicator(),
        ],
      ),
    );
  }
}

/// Animated three-dot indicator shown while the assistant is generating a reply.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.onBackground.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(KasyRadius.lg),
          topRight: Radius.circular(KasyRadius.lg),
          bottomLeft: Radius.circular(KasyRadius.xs),
          bottomRight: Radius.circular(KasyRadius.lg),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Each dot bounces at a slightly different phase.
              final double phase = (_controller.value - i * 0.2).clamp(0.0, 1.0);
              final double scale =
                  1.0 + 0.4 * (phase < 0.5 ? phase * 2 : (1.0 - phase) * 2);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.muted,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
