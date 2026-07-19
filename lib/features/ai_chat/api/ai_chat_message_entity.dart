/// Supabase row mapping for a single AI chat message.
/// Table: public.ai_messages
class AiChatMessageEntity {
  final String? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  const AiChatMessageEntity({
    this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AiChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return AiChatMessageEntity(
      id: json['id'] as String?,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
