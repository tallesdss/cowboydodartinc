# send-push-notification

Edge Function que envia push notifications via Firebase Cloud Messaging (FCM)
quando uma notificação é inserida na tabela `notifications`.

## Tudo isto é automático

O `kasy new` e o `kasy deploy` já deixam o push funcionando no Supabase, sem passo
manual:

- **Secrets** `FIREBASE_PROJECT_ID` e `FIREBASE_SERVICE_ACCOUNT_JSON` são definidos
  automaticamente (a chave de Service Account é gerada pela CLI).
- **A chamada automática** da função quando uma notificação é inserida vem de um
  **trigger no banco** (`pg_net`), criado pela migration
  `20240101000006_notification_webhook.sql`. **Não é** um Database Webhook do painel.
- O trigger só dispara quando `notify_user IS DISTINCT FROM false` (ex.: a notificação
  de boas-vindas usa `notify_user = false` porque o usuário já está dentro do app).

> ⚠️ **Não crie um Database Webhook no painel** apontando para esta função. O trigger
> `pg_net` já faz isso; um webhook duplicado faria o push **disparar duas vezes**.

## Fallback manual (só se a automação falhar)

Se por algum motivo os secrets não tiverem sido definidos, rode:

```bash
supabase secrets set FIREBASE_PROJECT_ID=your-firebase-project-id
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"..."}'
supabase functions deploy send-push-notification --project-ref YOUR_PROJECT_REF
```

O JSON do service account: Firebase Console → Project Settings → Service Accounts →
**Generate new private key**.

Se preferir o trigger via painel em vez do `pg_net` (não recomendado, e nunca os dois
ao mesmo tempo), use Database → Webhooks → Create webhook na tabela `notifications`,
evento `INSERT`, POST para
`https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-push-notification`,
header `Authorization: Bearer YOUR_SUPABASE_ANON_KEY`.
