import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_api.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_conversation_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logger/logger.dart';

/// The conversation currently open in the detail pane (null = none selected).
///
/// On wide layouts a null value shows the "pick a conversation" placeholder;
/// on phones a null value means the list is showing (no conversation pushed).
final selectedConversationIdProvider = StateProvider<String?>((ref) => null);

/// Loads and mutates the user's conversation list. Backend-agnostic: it only
/// talks to [aiChatApiProvider] and [AiChatConversationEntity], so this single
/// file is shared across the Firebase / Supabase / API templates.
final aiConversationsNotifierProvider =
    AsyncNotifierProvider<
      AiConversationsNotifier,
      List<AiChatConversationEntity>
    >(AiConversationsNotifier.new);

class AiConversationsNotifier
    extends AsyncNotifier<List<AiChatConversationEntity>> {
  final Logger _logger = Logger();

  String? get _userId => ref.read(userStateNotifierProvider).user.idOrNull;

  List<AiChatConversationEntity>? get _current => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  @override
  Future<List<AiChatConversationEntity>> build() async {
    final userId = _userId;
    if (userId == null) return const [];
    try {
      return await ref.read(aiChatApiProvider).loadConversations(userId);
    } catch (e) {
      _logger.e('Failed to load conversations: $e');
      // Graceful fallback: start with an empty list if the backend is down.
      return const [];
    }
  }

  /// Creates an empty conversation, prepends it to the list, and returns its id.
  Future<String?> create() async {
    final userId = _userId;
    if (userId == null) return null;
    try {
      final conversation = await ref
          .read(aiChatApiProvider)
          .createConversation(userId);
      state = AsyncData([conversation, ...?_current]);
      return conversation.id;
    } catch (e) {
      _logger.e('Failed to create conversation: $e');
      return null;
    }
  }

  /// Deletes a conversation (and its messages) and removes it from the list.
  Future<void> delete(String conversationId) async {
    final userId = _userId;
    if (userId == null) return;
    // Optimistic removal so the UI feels instant.
    state = AsyncData(
      (_current ?? const []).where((c) => c.id != conversationId).toList(),
    );
    if (ref.read(selectedConversationIdProvider) == conversationId) {
      ref.read(selectedConversationIdProvider.notifier).state = null;
    }
    try {
      await ref
          .read(aiChatApiProvider)
          .deleteConversation(userId, conversationId);
    } catch (e) {
      _logger.e('Failed to delete conversation: $e');
    }
  }

  /// Updates the denormalized last-message fields and moves the conversation to
  /// the top of the list. Called by the chat notifier after each message.
  void touch(
    String conversationId, {
    required String role,
    required String content,
    required DateTime at,
  }) {
    final current = _current;
    if (current == null) return;
    final index = current.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;
    final updated = current[index].copyWith(
      lastMessageRole: role,
      lastMessageContent: content,
      updatedAt: at,
    );
    final rest = [...current]..removeAt(index);
    state = AsyncData([updated, ...rest]);
  }
}
