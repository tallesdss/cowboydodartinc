import 'dart:convert';

import 'package:cowboydodartinc/core/config/app_env.dart';
import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_api.dart';
import 'package:cowboydodartinc/features/ai_chat/api/ai_chat_message_entity.dart';
import 'package:cowboydodartinc/features/ai_chat/providers/ai_conversations_notifier.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

const int _kMaxContextMessages = 20;

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.user(String content) =>
      ChatMessage(role: 'user', content: content);

  factory ChatMessage.assistant(String content) =>
      ChatMessage(role: 'assistant', content: content);

  factory ChatMessage.fromEntity(AiChatMessageEntity entity) =>
      ChatMessage(role: entity.role, content: entity.content);

  AiChatMessageEntity toEntity() => AiChatMessageEntity(
    role: role,
    content: content,
    createdAt: DateTime.now(),
  );
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isReplying;
  final bool streamingStarted;

  const AiChatState({
    required this.messages,
    this.isReplying = false,
    this.streamingStarted = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isReplying,
    bool? streamingStarted,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isReplying: isReplying ?? this.isReplying,
      streamingStarted: streamingStarted ?? this.streamingStarted,
    );
  }
}

final aiChatNotifierProvider =
    AsyncNotifierProvider<AiChatNotifier, AiChatState>(AiChatNotifier.new);

class AiChatNotifier extends AsyncNotifier<AiChatState> {
  final Logger _logger = Logger();

  String? _streamingConversationId;

  bool get _streamStillActive =>
      ref.read(selectedConversationIdProvider) == _streamingConversationId;

  @override
  Future<AiChatState> build() async {
    final conversationId = ref.watch(selectedConversationIdProvider);
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (conversationId == null || userId == null) {
      return const AiChatState(messages: []);
    }

    try {
      final entities = await ref
          .read(aiChatApiProvider)
          .loadMessages(userId, conversationId);
      return AiChatState(
        messages: entities.map(ChatMessage.fromEntity).toList(),
      );
    } catch (e) {
      _logger.e('Failed to load AI chat history: $e');
      return const AiChatState(messages: []);
    }
  }

  Future<void> sendMessage(String prompt) async {
    final conversationId = ref.read(selectedConversationIdProvider);
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (conversationId == null || current == null || current.isReplying) return;
    _streamingConversationId = conversationId;

    final userMsg = ChatMessage.user(prompt);
    state = AsyncData(
      current.copyWith(
        messages: [...current.messages, userMsg],
        isReplying: true,
        streamingStarted: false,
      ),
    );

    _persistMessage(userMsg, conversationId);

    final allMessages = (state as AsyncData<AiChatState>).value.messages;
    final history = allMessages.length > _kMaxContextMessages
        ? allMessages.sublist(allMessages.length - _kMaxContextMessages)
        : allMessages;
    await _requestReplyStream(history, conversationId);
  }

  Future<void> _requestReplyStream(
    List<ChatMessage> history,
    String conversationId,
  ) async {
    final t = ref.read(translationsProvider).ai_chat;
    final String aiChatEndpoint = AppEnv.aiChatEndpoint;

    if (aiChatEndpoint.isEmpty) {
      _finalizeAssistantMessage(t.error_not_configured);
      return;
    }

    final accessToken =
        await FirebaseAuth.instance.currentUser?.getIdToken();
    if (accessToken == null) {
      _finalizeAssistantMessage(t.error_not_configured);
      return;
    }

    final dio = Dio(
      BaseOptions(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final response = await dio.post<ResponseBody>(
        aiChatEndpoint,
        data: {
          'message': history.last.content,
          'history': history
              .map((e) => {'role': e.role, 'content': e.content})
              .toList(growable: false),
        },
        options: Options(responseType: ResponseType.stream),
      );

      final lineBuffer = StringBuffer();
      final contentBuffer = StringBuffer();

      await for (final chunk in response.data!.stream) {
        final text = utf8.decode(chunk, allowMalformed: true);
        lineBuffer.write(text);

        final raw = lineBuffer.toString();
        final lastNewline = raw.lastIndexOf('\n');
        if (lastNewline == -1) continue;

        final completeSection = raw.substring(0, lastNewline + 1);
        lineBuffer.clear();
        if (lastNewline < raw.length - 1) {
          lineBuffer.write(raw.substring(lastNewline + 1));
        }

        for (final line in completeSection.split('\n')) {
          final delta = _extractSSEDelta(line.trimRight());
          if (delta.isEmpty) continue;

          contentBuffer.write(delta);
          _appendStreamingChunk(contentBuffer.toString());
        }
      }

      final fullContent = contentBuffer.toString();
      if (fullContent.isNotEmpty) {
        _persistMessage(ChatMessage.assistant(fullContent), conversationId);
      } else {
        _finalizeAssistantMessage(t.error_no_reply);
        return;
      }

      final latest = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (latest != null && _streamStillActive) {
        state = AsyncData(
          latest.copyWith(isReplying: false, streamingStarted: false),
        );
      }
    } catch (error) {
      _logger.e('AI chat stream failed: $error');
      _finalizeAssistantMessage(t.error_network);
    }
  }

  void _appendStreamingChunk(String partialContent) {
    if (!_streamStillActive) return;
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;

    final msgs = current.messages;
    final newMsgs = current.streamingStarted
        ? [
            ...msgs.sublist(0, msgs.length - 1),
            ChatMessage.assistant(partialContent),
          ]
        : [...msgs, ChatMessage.assistant(partialContent)];

    state = AsyncData(
      AiChatState(messages: newMsgs, isReplying: true, streamingStarted: true),
    );
  }

  void _finalizeAssistantMessage(String content) {
    if (!_streamStillActive) return;
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => const AiChatState(messages: []),
    };
    final msgs = current.messages;
    final newMsgs = current.streamingStarted
        ? [...msgs.sublist(0, msgs.length - 1), ChatMessage.assistant(content)]
        : [...msgs, ChatMessage.assistant(content)];
    state = AsyncData(AiChatState(messages: newMsgs));
  }

  String _extractSSEDelta(String line) {
    if (!line.startsWith('data: ')) return '';
    final payload = line.substring(6);
    if (payload == '[DONE]') return '';
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;

      final choices = json['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final delta =
            (choices.first as Map<String, dynamic>)['delta']
                as Map<String, dynamic>?;
        return (delta?['content'] as String?) ?? '';
      }

      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content =
            (candidates.first as Map<String, dynamic>)['content']
                as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return ((parts.first as Map<String, dynamic>)['text'] as String?) ??
              '';
        }
      }
    } catch (_) {}
    return '';
  }

  void _persistMessage(ChatMessage message, String conversationId) {
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId == null) return;
    final entity = message.toEntity();
    ref
        .read(aiChatApiProvider)
        .saveMessage(userId, conversationId, entity)
        .catchError((e) {
          _logger.e('Failed to persist message: $e');
        });
    // Keep the conversation list preview + ordering in sync.
    ref
        .read(aiConversationsNotifierProvider.notifier)
        .touch(
          conversationId,
          role: message.role,
          content: message.content,
          at: entity.createdAt,
        );
  }
}
