import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_conversation_entity.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_message_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final aiChatApiProvider = Provider<AiChatApi>(
  (ref) => AiChatApi(client: Supabase.instance.client),
);

const _kConversationsTable = 'ai_conversations';
const _kMessagesTable = 'ai_messages';

/// One user has many conversations (public.ai_conversations), each with many
/// messages (public.ai_messages, linked by conversation_id).
class AiChatApi {
  final SupabaseClient _client;
  final Logger _logger = Logger();

  AiChatApi({required SupabaseClient client}) : _client = client;

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  /// Returns the user's conversations, most recently updated first.
  Future<List<AiChatConversationEntity>> loadConversations(
    String userId,
  ) async {
    final rows = await _client
        .from(_kConversationsTable)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return rows.map(AiChatConversationEntity.fromJson).toList();
  }

  /// Creates an empty conversation and returns it (with its generated id).
  Future<AiChatConversationEntity> createConversation(String userId) async {
    final row = await _client
        .from(_kConversationsTable)
        .insert({'user_id': userId})
        .select()
        .single();
    return AiChatConversationEntity.fromJson(row);
  }

  /// Deletes a conversation; its messages cascade via the foreign key.
  Future<void> deleteConversation(String userId, String conversationId) async {
    await _client.from(_kConversationsTable).delete().eq('id', conversationId);
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  /// Returns all messages in a conversation, oldest first.
  Future<List<AiChatMessageEntity>> loadMessages(
    String userId,
    String conversationId,
  ) async {
    final rows = await _client
        .from(_kMessagesTable)
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return rows.map(AiChatMessageEntity.fromJson).toList();
  }

  /// Persists a message and denormalizes it onto the parent conversation
  /// (last message preview + updated_at) so the list stays cheap to render.
  Future<void> saveMessage(
    String userId,
    String conversationId,
    AiChatMessageEntity message,
  ) async {
    try {
      await _client.from(_kMessagesTable).insert({
        'user_id': userId,
        'conversation_id': conversationId,
        ...message.toJson(),
      });
      await _client
          .from(_kConversationsTable)
          .update({
            'updated_at': message.createdAt.toUtc().toIso8601String(),
            'last_message_role': message.role,
            'last_message_content': message.content,
          })
          .eq('id', conversationId);
    } catch (e) {
      _logger.e('Failed to persist AI message: $e');
    }
  }
}
