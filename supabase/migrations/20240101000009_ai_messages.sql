-- AI chat history (one user has many conversations, each with many messages).

-- Conversations. The last message is denormalized onto the row so the list can
-- be rendered with a single query (no need to read each conversation's messages
-- just to show a preview + timestamp).
CREATE TABLE IF NOT EXISTS public.ai_conversations (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  last_message_role    TEXT        CHECK (last_message_role IN ('user', 'assistant')),
  last_message_content TEXT,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Row Level Security: users can only access their own conversations.
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own ai conversations"
  ON public.ai_conversations
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for listing a user's conversations, most recently updated first.
CREATE INDEX IF NOT EXISTS ai_conversations_user_updated_at_idx
  ON public.ai_conversations (user_id, updated_at DESC);

-- Messages. Each row stores one message (user or assistant) inside a
-- conversation. user_id is kept for a simple RLS policy.
CREATE TABLE IF NOT EXISTS public.ai_messages (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID        NOT NULL REFERENCES public.ai_conversations(id) ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role            TEXT        NOT NULL CHECK (role IN ('user', 'assistant')),
  content         TEXT        NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Row Level Security: users can only access their own messages.
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own ai messages"
  ON public.ai_messages
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for fast ordered queries within a conversation.
CREATE INDEX IF NOT EXISTS ai_messages_conversation_created_at_idx
  ON public.ai_messages (conversation_id, created_at ASC);
