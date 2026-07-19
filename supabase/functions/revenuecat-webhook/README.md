# RevenueCat Webhook + Meta Ads

Supabase Edge Function que recebe eventos do RevenueCat, sincroniza assinaturas no banco e envia conversões para a Meta Conversions API.

## Pré-requisitos

- Tabela `subscriptions` com colunas: `user_id`, `status`, `creation_date`, `last_update_date`, `period_end_date`, `sku_id`, `offer_id`
- Tabela `devices` com `extra_data` (JSONB) contendo `anonymousFbId` para Meta Ads (enviado pelo app Flutter)

## Secrets

Configure antes do deploy:

```bash
supabase secrets set REVENUECAT_WEBHOOK_KEY="Bearer seu_token_do_revenuecat"
supabase secrets set META_ACCESS_TOKEN="seu_token_meta"
supabase secrets set META_DATASET_ID="seu_pixel_id"
```

## Deploy

```bash
supabase functions deploy revenuecat-webhook
```

## Configuração no RevenueCat

1. RevenueCat Dashboard → Project → Integrations → Webhooks
2. URL: `https://<seu-projeto>.supabase.co/functions/v1/revenuecat-webhook`
3. Authorization: o mesmo valor de `REVENUECAT_WEBHOOK_KEY` (ex: `Bearer xxx`)
