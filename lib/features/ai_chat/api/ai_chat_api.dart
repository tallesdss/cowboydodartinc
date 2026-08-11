import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_conversation_entity.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_message_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final aiChatApiProvider = Provider<AiChatApi>(
  (ref) => AiChatApi(firestore: FirebaseFirestore.instance),
);

const _kConversationsCollection = 'ai_conversations';
const _kMessagesCollection = 'ai_messages';

class AiChatApi {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  AiChatApi({required FirebaseFirestore firestore}) : _firestore = firestore;

  // ───────────────────────────────────────────────────────────────────────────
  // Conversations
  // ───────────────────────────────────────────────────────────────────────────

  /// Returns the user's conversations, most recently updated first.
  Future<List<AiChatConversationEntity>> loadConversations(
    String userId,
  ) async {
    final snap = await _firestore
        .collection(_kConversationsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_at', descending: true)
        .get();
    return snap.docs.map((doc) => AiChatConversationEntity.fromJson(doc.data())).toList();
  }

  /// Creates an empty conversation and returns it (with its generated id).
  Future<AiChatConversationEntity> createConversation(String userId) async {
    final docRef = _firestore.collection(_kConversationsCollection).doc();
    final data = {
      'id': docRef.id,
      'user_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await docRef.set(data);
    return AiChatConversationEntity.fromJson(data);
  }

  /// Deletes a conversation; its messages cascade.
  Future<void> deleteConversation(String userId, String conversationId) async {
    final snap = await _firestore
        .collection(_kMessagesCollection)
        .where('conversation_id', isEqualTo: conversationId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.collection(_kConversationsCollection).doc(conversationId));
    await batch.commit();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Messages
  // ───────────────────────────────────────────────────────────────────────────

  /// Returns all messages in a conversation, oldest first.
  Future<List<AiChatMessageEntity>> loadMessages(
    String userId,
    String conversationId,
  ) async {
    final snap = await _firestore
        .collection(_kMessagesCollection)
        .where('conversation_id', isEqualTo: conversationId)
        .orderBy('created_at', descending: false)
        .get();
    return snap.docs.map((doc) => AiChatMessageEntity.fromJson(doc.data())).toList();
  }

  /// Persists a message and denormalizes it onto the parent conversation.
  Future<void> saveMessage(
    String userId,
    String conversationId,
    AiChatMessageEntity message,
  ) async {
    try {
      final docRef = _firestore.collection(_kMessagesCollection).doc();
      final data = {
        'id': docRef.id,
        'user_id': userId,
        'conversation_id': conversationId,
        ...message.toJson(),
      };
      await docRef.set(data);

      await _firestore
          .collection(_kConversationsCollection)
          .doc(conversationId)
          .update({
            'updated_at': message.createdAt.toUtc().toIso8601String(),
            'last_message_role': message.role,
            'last_message_content': message.content,
          });
    } catch (e) {
      _logger.e('Failed to persist AI message: $e');
    }
  }
}
