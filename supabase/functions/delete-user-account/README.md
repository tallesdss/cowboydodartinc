# delete-user-account

Edge Function que remove o usuário autenticado de `auth.users`. Obrigatória para conformidade com as lojas (Apple, Google) — o usuário deve poder excluir sua conta.

Ao deletar em `auth.users`:
- `public.users` é removido via `ON DELETE CASCADE`
- `devices`, `subscriptions`, `feature_votes`, `user_infos`, `notifications` são removidos em cascata

## Deploy

```bash
supabase functions deploy delete-user-account --project-ref YOUR_PROJECT_REF
```

Não requer secrets — usa `SUPABASE_SERVICE_ROLE_KEY` e `SUPABASE_ANON_KEY` já disponíveis no runtime.
