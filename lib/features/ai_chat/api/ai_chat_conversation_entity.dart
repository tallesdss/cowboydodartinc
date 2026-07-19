/// Supabase row mapping for a single AI chat conversation.
/// Table: public.ai_conversations
///
/// The last message is denormalized onto the conversation so the list can be
/// rendered with a single query (no need to read each conversation's messages
/// just to show a preview + timestamp).
class AiChatConversationEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Role of the most recent message ('user' or 'assistant'), or null when the
  /// conversation has no messages yet.
  final String? lastMessageRole;

  /// Content of the most recent message, or null when empty.
  final String? lastMessageContent;

  const AiChatConversationEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageRole,
    this.lastMessageContent,
  });

  bool get isEmpty => lastMessageContent == null;

  AiChatConversationEntity copyWith({
    DateTime? updatedAt,
    String? lastMessageRole,
    String? lastMessageContent,
  }) {
    return AiChatConversationEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageRole: lastMessageRole ?? this.lastMessageRole,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
    );
  }

  factory AiChatConversationEntity.fromJson(Map<String, dynamic> json) {
    return AiChatConversationEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageRole: json['last_message_role'] as String?,
      lastMessageContent: json['last_message_content'] as String?,
    );
  }
}
