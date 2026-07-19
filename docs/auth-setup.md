# Configurar autenticação social

Guia para ativar login com Google, Apple e Facebook no seu projeto.

---

## Google Sign-In

A CLI já faz a parte técnica automaticamente ao gerar o projeto:
- Lê o `REVERSED_CLIENT_ID` do `GoogleService-Info.plist`
- Registra o URL scheme no `ios/Runner/Info.plist`
- Grava o `lib/google_auth_options.dart` com o Web Client ID

**O que você precisa verificar uma única vez:**

1. [Firebase Console → Authentication → Sign-in method → Google](https://console.firebase.google.com/project/_/authentication/providers) → ativar
2. A CLI já adiciona o SHA-1 do debug keystore automaticamente no Android. Se usar um computador novo ou keystore diferente, verifique com:
```bash
kasy doctor
```

---

## Apple Sign-In

Requer conta [Apple Developer](https://developer.apple.com) (paga).

### Passo 1 — Ativar capability no Bundle ID

1. Abra [Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. Selecione seu Bundle ID
3. Ative **Sign In with Apple** → Enable as a primary App ID → **Save**

### Passo 2 — Criar chave

1. Abra [Keys](https://developer.apple.com/account/resources/authkeys/list)
2. Clique em **+** → dê um nome (ex: `Firebase Sign In with Apple`)
3. Ative **Sign In with Apple** → Configure → selecione seu Bundle ID → Save
4. Registre → **baixe o `.p8`** (só é possível baixar uma vez — guarde em lugar seguro)
5. Anote o **Key ID** (ex: `6RR89XG535`)

### Passo 3 — Criar Services ID

1. Abra [Services IDs](https://developer.apple.com/account/resources/identifiers/list/serviceId)
2. Clique em **+** → selecione **Services IDs** → Continue
3. Preencha:
   - **Description**: `Firebase Sign In with Apple`
   - **Identifier**: `SEU_BUNDLE_ID.signin` (ex: `com.empresa.app.signin`)
4. Registre → clique no Services ID recém-criado → ative **Sign In with Apple** → Configure
5. Preencha:
   - **Primary App ID**: seu Bundle ID
   - **Domains**: `SEU_PROJETO.firebaseapp.com`
   - **Return URLs**: `https://SEU_PROJETO.firebaseapp.com/__/auth/handler`
6. Next → Done → Continue → **Save**

### Passo 4 — Configurar no Firebase

1. Abra [Firebase Console → Authentication → Apple](https://console.firebase.google.com/project/_/authentication/providers)
2. Ative o provedor Apple
3. Preencha em **Configuração do fluxo de código OAuth**:
   - **Services ID**: o identifier do Passo 3 (ex: `com.empresa.app.signin`)
   - **Team ID**: encontrado em [Membership Details](https://developer.apple.com/account#MembershipDetailsCard)
   - **ID da chave**: o Key ID do Passo 2
   - **Chave privada**: conteúdo completo do arquivo `.p8`, incluindo as linhas `-----BEGIN PRIVATE KEY-----` e `-----END PRIVATE KEY-----`
4. **Salvar**

### Passo 5 — Ativar capability no Xcode

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Target **Runner** → **Signing & Capabilities** → **+ Capability** → adicione **Sign In with Apple**

> **iOS / macOS**: o botão Apple aparece automaticamente depois dos passos acima.
>
> **Android**: o botão Apple fica escondido por padrão (exige o fluxo do Services ID pago e agrega pouco no Android para um SaaS). Deixe escondido.
>
> **Web (Firebase)**: depois dos Passos 1 a 3, rode `kasy apple-web` — ele grava o Services ID + Team ID + Key ID + `.p8` no provedor Apple do Firebase e liga `withAppleWebSignin` (que nasce `false`). A Return URL do Services ID (`firebaseapp.com/__/auth/handler`) cobre o fluxo de popup. O Firebase re-assina o secret sozinho (não expira).
>
> **Web (Supabase)**: Apple na web no Supabase **não vem ligado no app ainda** (roadmap) — o botão fica escondido na web. No Supabase, o Apple funciona só no **iOS nativo** (já configurado pelo `kasy new`). Veja `ROADMAP.md`.

---

## Facebook Sign-In

Requer conta no [Meta for Developers](https://developers.facebook.com).

> **Atalho:** o comando `kasy facebook` automatiza a parte de gravar as credenciais (Info.plist, strings.xml e o provedor no Firebase/Supabase) e abre o painel da Meta. Os passos abaixo são o que você faz na Meta (manual, sem API).

### Passo 1 — Criar app no Meta

1. Abra [Meta for Developers → My Apps](https://developers.facebook.com/apps)
2. Clique em **Create App** → selecione **Consumer** → Next
3. Preencha o nome do app → Create App
4. No painel do app, anote o **App ID** e o **Client Token** (Settings → Advanced → Client Token)

### Passo 2 — Ativar Facebook Login

1. No painel do app Meta → Add Product → **Facebook Login** → Set Up → iOS/Android conforme necessário
2. iOS: informe o Bundle ID do seu app

### Passo 3 — iOS: atualizar Info.plist

Edite `ios/Runner/Info.plist` e substitua os placeholders:

```xml
<key>FacebookAppID</key>
<string>SEU_APP_ID</string>
<key>FacebookClientToken</key>
<string>SEU_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Nome do seu app</string>
```

E o URL scheme (dentro de `CFBundleURLTypes`):
```xml
<string>fbSEU_APP_ID</string>
```

### Passo 4 — Android: atualizar strings.xml

Edite `android/app/src/main/res/values/strings.xml` e substitua os placeholders:

```xml
<string name="facebook_app_id">SEU_APP_ID</string>
<string name="facebook_client_token">SEU_CLIENT_TOKEN</string>
```

### Passo 5 — Web: adicionar domínio no Meta

1. No painel do app Meta → Facebook Login → Settings
2. Em **Valid OAuth Redirect URIs**, adicione `https://SEU_PROJETO.firebaseapp.com/__/auth/handler`
3. Em **Allowed Domains for the JavaScript SDK**, adicione `SEU_PROJETO.firebaseapp.com`

Verifique com:
```bash
kasy doctor
```

---

## Supabase

Para projetos com backend Supabase, a configuração do lado da Apple e do Meta é idêntica. O que muda é onde cadastrar as credenciais:

| Provedor | Onde configurar |
|----------|----------------|
| Google | Supabase Dashboard → Auth → Providers → Google |
| Apple | Supabase Dashboard → Auth → Providers → Apple (Services ID obrigatório) |
| Facebook | Supabase Dashboard → Auth → Providers → Facebook |

No Apple com Supabase, o **Return URL** do Services ID deve ser:
```
https://SEU_PROJETO.supabase.co/auth/v1/callback
```
