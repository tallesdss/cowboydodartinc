# Kasy App

Flutter app com backend Supabase — gerado pelo kasy.

---

## Documentação

A documentação completa do Kasy está em **[kasy.dev/docs](https://kasy.dev/docs)** — instalação, features, personalização, publicação e troubleshooting, passo a passo.

Neste projeto você também tem guias locais (funcionam offline):

| Guia | Conteúdo |
|------|----------|
| [docs/auth-setup.md](docs/auth-setup.md) | Ativar login com Google, Apple e Facebook |
| [docs/revenuecat-setup.md](docs/revenuecat-setup.md) | Ativar assinaturas (RevenueCat) do teste à produção |
| [docs/ad_mobs.md](docs/ad_mobs.md) | Anúncios (AdMob) e recompensas verificadas |
| [docs/ios-release.md](docs/ios-release.md) | Publicar no iOS com Mac (`kasy ios`) |
| [docs/codemagic-release.md](docs/codemagic-release.md) | Publicar sem Mac (`kasy codemagic`) |
| [docs/figma-workflow.md](docs/figma-workflow.md) | Fluxo Figma → Flutter para assistentes de IA |
| [docs/figma-guia.md](docs/figma-guia.md) | Guia Figma passo a passo (rebrand e telas) |
| [design/README.md](design/README.md) | Design system Figma (link Community + duplicate) |

---

## Como começar

```sh
kasy run             # recomendado — lê o .env e escolhe as chaves certas
kasy run --ios       # simulador iOS
kasy run --android   # emulador Android
kasy run --web       # web em localhost:5555
```

Alternativas: `make run` ou `flutter run` funcionam, mas sem os extras do `kasy run` (escolha automática de chave RevenueCat, log em `.kasy/run.log`, aviso de update).

**Dispositivo físico via cabo**
- iOS: conecte o iPhone → confie neste computador → Xcode → Window → Devices → parear
- Android: Configurações → Opções do desenvolvedor → ativar depuração USB

**Deploy do banco de dados** (quando estiver pronto):

```sh
supabase link --project-ref SEU_PROJECT_REF
supabase db push
```

**Deploy das Edge Functions**:

```sh
supabase functions deploy delete-user-account   # obrigatória para exclusão de conta
supabase functions deploy revenuecat-webhook   # se usar RevenueCat
supabase functions deploy send-push-notification   # se usar push
```

**Secrets do servidor** (se usar RevenueCat):

```sh
supabase secrets set REVENUECAT_WEBHOOK_KEY="sua_chave"
supabase secrets set META_ACCESS_TOKEN="seu_token"   # opcional
supabase secrets set META_DATASET_ID="seu_dataset"   # opcional
```

---

## Autenticação

O app já tem o código para todos os providers. O que precisa ser ativado no dashboard:

| Provider | Status | Como ativar |
|----------|--------|-------------|
| Email/Senha | ✅ Ativo por padrão | — |
| Anônimo | ⚙️ Ativar manualmente | Dashboard → Authentication → Settings → **Allow anonymous sign-ins** |
| Google | ⚙️ Ativar manualmente | Dashboard → Authentication → Providers → Google → inserir Client ID e Secret do Google Cloud Console |
| Apple | ⚙️ Ativar manualmente | Dashboard → Authentication → Providers → Apple |

> **Dica para testar:** ative o login anônimo primeiro — é o mais rápido e não precisa de OAuth credentials.

---

## Chaves e credenciais

Este projeto usa dois tipos de credenciais. Entender a diferença evita confusão na hora de configurar.

### Chaves do app (ficam no projeto)

Ficam no arquivo **`.env`** na raiz do projeto (cada chave tem um comentário explicando). O `kasy run` lê o `.env` e injeta os valores no build via `--dart-define`; o Flutter lê com `String.fromEnvironment()`. **Nunca vão para o servidor.**

| Variável | Módulo | Como obter |
|----------|--------|------------|
| `BACKEND_URL` | Supabase | Dashboard Supabase → Project Settings → API → Project URL |
| `SUPABASE_TOKEN` | Supabase | Dashboard Supabase → Project Settings → API → anon key |
| `RC_TEST_KEY` | RevenueCat | Dashboard RevenueCat → Apps → Test Store (chave `test_`, vale iOS+Android, usada automaticamente em simulador) |
| `RC_IOS_PROD_KEY` | RevenueCat | Dashboard RevenueCat → Apps → App Store (chave `appl_`, usada automaticamente em iPhone físico) |
| `RC_ANDROID_PROD_KEY` | RevenueCat | Dashboard RevenueCat → Apps → Google Play (chave `goog_`, usada automaticamente em Android físico) |
| `SENTRY_DSN` | Sentry | Dashboard Sentry → Projeto → DSN |
| `MIXPANEL_TOKEN` | Mixpanel | Dashboard Mixpanel → Configurações → Token |

Para atualizar uma chave, edite o `.env` e rode `kasy run` de novo.

---

## Internacionalização (i18n)

O app suporta **3 idiomas**: inglês (`en`), português (`pt`) e espanhol (`es`).

### Como o idioma é escolhido

```
App abre
  ├─ Tem idioma salvo pelo usuário? → usa o salvo
  └─ Não tem → lê o idioma do celular/browser
                ├─ É en, pt ou es? → usa esse idioma
                └─ Não é nenhum desses → usa o idioma padrão (base_locale)
```

### Mudar o idioma padrão (fallback)

**`slang.yaml`**
```yaml
base_locale: pt   # trocar aqui: en | pt | es
```

Depois rodar:
```sh
dart run slang
```

### Adicionar ou editar traduções

Os arquivos ficam em `lib/i18n/`:
- `en.i18n.json` — inglês
- `pt.i18n.json` — português
- `es.i18n.json` — espanhol

Após editar qualquer `.i18n.json`, sempre rodar `dart run slang`.

---

## Segurança

O `.gitignore` já exclui: `.env`, `.env.*`, `*.pem`, `*.keystore`.

Nunca comite credenciais no repositório.
