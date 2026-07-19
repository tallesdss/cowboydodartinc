# Configurar RevenueCat

Guia para ativar assinaturas e compras no app depois que a CLI gerou o projeto.

---

## O que a CLI já fez por você

| Já pronto | O que ainda falta |
|-----------|-------------------|
| Instalou `purchases_flutter` | Criar conta no RevenueCat |
| Configurou as chaves no `.env` (test/iOS prod/Android prod) | Criar Produtos, Entitlements e Offerings no painel RC |
| Gerou o código do paywall e do repositório de assinaturas | Registrar a URL do webhook no painel RC |
| Firebase: implantou a Cloud Function do webhook | — |
| Supabase: implantou a Edge Function do webhook | — |

> As chaves ficam em `.env` na raiz (fonte da verdade) e refletidas no `.vscode/launch.json` + `Makefile`. Todos no `.gitignore` — nunca vão para o repositório.

### Qual chave usar?

A CLI pergunta **três chaves opcionais** (pelo menos uma é obrigatória):

| Variável | Prefixo | Uso |
|---|---|---|
| `RC_TEST_KEY` | `test_` | Test Store. **Uma chave única**, vale iOS+Android. Usada automaticamente em simulador/emulador. |
| `RC_IOS_PROD_KEY` | `appl_` | App Store (Sandbox + Produção). Usada automaticamente em iPhone físico. |
| `RC_ANDROID_PROD_KEY` | `goog_` | Google Play (Sandbox + Produção). Usada automaticamente em Android físico. |

O `kasy run` escolhe a chave certa baseado no device. Forçar manual: `kasy run --rc=test` ou `kasy run --rc=prod`.

---

## Passo 1 — Criar conta e projeto no RevenueCat

1. Acesse [app.revenuecat.com](https://app.revenuecat.com) → crie uma conta gratuita
2. Crie um projeto → dê um nome (ex: nome do seu app)

---

## Passo 2 — Criar o app no RevenueCat

Ainda dentro do projeto:

**Para começar (Test Store — sem Apple/Google)**

Project → Apps → **+ Add app** → selecione **Test Store** → copie a chave `test_xxx`.

Cole essa mesma chave quando a CLI pedir tanto para iOS quanto para Android (ou atualize manualmente nos arquivos se o projeto já existia).

**Para produção**

Crie um app separado para cada plataforma:
- **App Store** → chave começa com `appl_`
- **Google Play** → chave começa com `goog_`

> ⚠️ **Regra crítica:** o tipo do app e o prefixo da chave precisam bater. `Test Store` → `test_`, `App Store` → `appl_`, `Google Play` → `goog_`. Usar a chave errada causa `INVALID_CREDENTIALS`.

---

## Passo 3 — Criar Produtos, Entitlements e Offerings

Você pode fazer isso pelo painel ou pedir ao Claude com o MCP do RevenueCat ("Crie um produto `premium_monthly`, entitlement `premium_access` e offering `default`").

**Pelo painel RC** (mesma URL para todos os projetos):

1. [app.revenuecat.com](https://app.revenuecat.com) → seu projeto → **Products** → `+ New`
   - Crie os planos (ex: `premium_monthly`, `premium_annual`)
   - Os IDs devem ser **idênticos** aos que você vai criar na App Store / Google Play

2. **Entitlements** → `+ New`
   - Crie `premium_access` → clique no entitlement → **Attach** → selecione os produtos

3. **Offerings** → `+ New`
   - Crie `default` → entre no offering → `+ Add package` → selecione os produtos

> **Sobre os IDs dos produtos:** o caractere por caractere precisa ser igual. `premium_monthly` na App Store e `premium_monthly` no RC — qualquer diferença e o produto não aparece no paywall.

---

## Passo 4 — Configurar o webhook

O webhook mantém a tabela `subscriptions` do seu banco atualizada a cada compra, renovação ou cancelamento.

**A URL da função já foi implantada pela CLI. Você só precisa registrá-la no RevenueCat.**

Encontre a URL da função:

| Backend | Onde encontrar a URL |
|---------|---------------------|
| **Supabase** | `https://SEU_PROJECT_REF.supabase.co/functions/v1/revenuecat-webhook` |
| **Firebase** | [Firebase Console → Functions](https://console.firebase.google.com/project/_/functions) → `subscriptions-revenuecatWebhook` → copie a URL |

Registre no RevenueCat:

1. [app.revenuecat.com](https://app.revenuecat.com) → seu projeto → **Integrations** → **Webhooks** → `+ Add webhook`
2. Preencha:

| Campo | O que colocar |
|-------|---------------|
| **Webhook name** | Qualquer nome (ex: `firebase` ou `supabase`) |
| **Webhook URL** | A URL da função acima |
| **Authorization header value** | `Bearer ` + o valor de `REVENUECAT_WEBHOOK_KEY` (ex: `Bearer rc_wh_abc123`) |
| **Environment** | `Both Production and Sandbox` |
| **Events filter** | `All apps` / `All events` |

3. Clique em **Send test event** — se retornar `200 OK`, está funcionando.

> ⚠️ **Header de autorização:** o campo deve conter `Bearer ` seguido do seu token — incluindo o espaço. A função rejeita qualquer header que não siga esse formato.

---

## Passo 5 — iOS: configurar na App Store Connect

Necessário quando você sair do Test Store e quiser testar com compras reais no iPhone.

**Custo:** USD $99/ano (Apple Developer Program)

Siga exatamente essa ordem — pular qualquer passo faz os produtos não aparecerem.

**1. Criar a conta Apple Developer**

[developer.apple.com](https://developer.apple.com) → crie a conta e pague o USD $99/ano.

**2. Configurar negócios — obrigatório para o Sandbox funcionar**

> ⚠️ **Este é o passo mais ignorado e o mais bloqueante.** Sem ele, o Sandbox retorna lista vazia de produtos mesmo que você tenha feito tudo certo: conta RC, produto criado, Sandbox Tester configurado no iPhone. Nada funciona.

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → menu superior → **Agreements, Tax, and Banking**:

- Aceite o **Paid Applications Agreement** (contrato de parceria com a Apple)
- Cadastre a **conta bancária** onde você vai receber
- Preencha os **formulários fiscais** (país, tipo de pessoa física ou jurídica)
- Aceite as **conformidades** exigidas
- Se for vender para a Europa: preencha as informações públicas adicionais exigidas

Após preencher tudo, **aguarde de 4 a 6 horas** para as configurações propagarem. Só depois disso o Sandbox começa a funcionar corretamente. Tentar antes disso retorna lista vazia ou erros genéricos.

**3. Criar o app no App Store Connect**

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **My Apps** → `+` → **New App** → use o mesmo Bundle ID do projeto Flutter.

**4. Criar as assinaturas**

App Store Connect → seu app → **Monetização** → **Assinaturas**:

a) **Criar o grupo de assinaturas** (ex: "Premium") — todas as assinaturas ficam dentro de um grupo.

b) **Configurar o período de tolerância** (opcional mas recomendado): clique em **Período de tolerância** → **Editar** → escolha a duração. Recomendado: **3 dias** para a maioria dos apps. Serve para manter o acesso do assinante durante falhas de pagamento temporárias antes de cancelar.

c) **Criar os produtos** dentro do grupo:
   - Adicione os produtos com os mesmos IDs do RevenueCat (ex: `subscription_monthly_01`)
   - Preencha: preço, duração, idioma da assinatura e captura de tela

d) **Configurar o idioma do grupo** — passo que muita gente esquece:

   Dentro do grupo → seção **Idioma** → `+` → selecione o idioma (ex: Inglês EUA) → preencha **Nome de exibição do grupo** (ex: `premium`) → salve.

   > ⚠️ **Sem este passo os produtos ficam presos em "Missing Metadata"** e nunca avançam para "Preparar para envio" nem "Pronto para envio", mesmo com preço, idioma e captura de tela da assinatura preenchidos. O idioma do **grupo** é diferente do idioma da assinatura individual.

e) **Captura de tela da assinatura** (obrigatório para envio à revisão):

   Tire um screenshot do paywall do seu app rodando no simulador iOS ou no iPhone físico (`make run-ios` → abra a tela premium). Use essa imagem no campo **Captura de tela** de cada assinatura. O campo **Notas para a equipe de revisão** é opcional — você pode descrever brevemente o produto.

Após preencher tudo e configurar o idioma do grupo, o status sai de **Missing Metadata** → **Preparar para envio** → **Pronto para envio**. Qualquer um dos dois últimos já está correto.

**5. Criar o app no RevenueCat como App Store**

[app.revenuecat.com](https://app.revenuecat.com) → seu projeto → **Apps** → `+ Add app` → **App Store** → copie a chave `appl_xxx`.

Cole no `.env` da raiz:

```env
RC_IOS_PROD_KEY=appl_xxxxxxxxxxxxxxx
```

O `kasy run` usa essa chave automaticamente em iPhone físico (simulador continua com `RC_TEST_KEY`).

**6. Criar Sandbox Tester — obrigatório para testar no iPhone físico**

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Users and Access** → aba **Sandbox** → **Testers** → `+`

Crie um e-mail que **não tenha nenhuma conta Apple associada** (um Gmail novo funciona bem). O e-mail precisa ser acessível — a Apple envia um código de verificação para confirmar a conta.

> O Sandbox Tester **não é** uma conta Apple ID real. É uma conta exclusiva para testes que só funciona no ambiente Sandbox. Sem ela, o iPhone pede o Apple ID normal e a compra vai para produção.

**7. Ativar Developer Mode no iPhone (iOS 16+)**

Obrigatório para rodar apps direto do Xcode/terminal no dispositivo físico.

iPhone → **Ajustes** → **Privacidade e Segurança** → role até o final → **Modo de Desenvolvedor** → ative → o iPhone reinicia para confirmar.

> Se a opção não aparecer, conecte o iPhone ao Mac com Xcode aberto pelo menos uma vez — isso desbloqueará o Modo de Desenvolvedor.

**8. Conectar a conta Sandbox no iPhone**

Nos iPhones modernos (iOS 16+), a conta Sandbox fica dentro da seção Desenvolvedor:

iPhone → **Ajustes** → role até o final → **Desenvolvedor** → role até o final da página → **Conta Sandbox** → **Entrar** → use o e-mail e senha do Sandbox Tester criado.

> Em versões anteriores do iOS, o caminho era Ajustes → App Store → Conta Sandbox. Nos iPhones atuais o caminho correto é pelo menu Desenvolvedor conforme acima.

**9. Configurar a chave P8 (recomendado para sandbox, obrigatório para produção)**

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **In-App Purchase** → `+` → baixe o `.p8` → cole no RevenueCat em **App Settings** → **In-App Purchase Key**.

> Você só pode baixar a P8 uma vez. Guarde em local seguro.

**9. Rodar no iPhone físico**

```bash
make run-ios
```

Faça uma compra — o modal real da Apple aparece. Com a conta Sandbox ativa, a compra não cobra nada.

---

## Passo 6 — Android: configurar no Google Play Console

Necessário quando você sair do Test Store e quiser testar com compras reais no Android.

**Custo:** USD $25 (pagamento único)

**1. Criar a conta Google Play Developer**

[play.google.com/console](https://play.google.com/console) → crie a conta e pague o USD $25.

**2. Configurar o perfil de pagamento**

Google Play Console → **Configurações** (menu lateral principal) → **Conta do desenvolvedor** → **Perfil de pagamentos** → preencha nome legal, endereço e dados fiscais.

**3. Criar o app**

Google Play Console → **Criar app** → preencha nome, idioma e categoria.

**4. Publicar no track de Teste Interno — obrigatório para criar assinaturas**

**Testes** → **Testes internos** → crie a release → suba um APK/AAB assinado → publique.

> O app não precisa estar completo — uma versão de desenvolvimento assinada serve.

**5. Criar as assinaturas**

Google Play Console → seu app → **Monetizar** → **Assinaturas** → `+ Criar assinatura`:
- Crie os produtos com os mesmos IDs do RevenueCat
- Deixe em estado `Ativo`

**6. Criar a Service Account (credencial do RevenueCat para o Google)**

a) [console.cloud.google.com](https://console.cloud.google.com) → selecione o projeto do app → **APIs e serviços** → **Biblioteca** → ative:
   - **Google Play Android Developer API**
   - **Google Play Developer Reporting API**

b) **IAM e administrador** → **Contas de serviço** → **+ Criar conta de serviço**:
   - Nome: `revenuecat-service` (ou qualquer nome)
   - Papéis: **Editor do Pub/Sub** + **Leitor de monitoramento**
   - Clique em **Concluído**

c) Clique na conta criada → aba **Chaves** → **Adicionar chave** → **Criar nova chave** → **JSON** → baixe o arquivo.

d) Google Play Console → **Configurações** → **Usuários e permissões** → **Convidar novos usuários**:
   - E-mail: o e-mail da Service Account (visível no Cloud Console)
   - Permissões: **Gerenciar pedidos e assinaturas** + **Gerenciar relatórios financeiros**
   - Salve

> Após configurar, aguarde até 36 horas para as credenciais propagarem. Erros 503/521 no RC durante esse período são normais.

**7. Configurar no RevenueCat com credenciais Google**

[app.revenuecat.com](https://app.revenuecat.com) → seu projeto → **Apps** → `+ Add app` → **Google Play** → faça upload do arquivo JSON → copie a chave `goog_xxx`.

Cole no `.env` da raiz:

```env
RC_ANDROID_PROD_KEY=goog_xxxxxxxxxxxxxxx
```

O `kasy run` usa essa chave automaticamente em Android físico (emulador continua com `RC_TEST_KEY`).

**8. Adicionar License Tester — obrigatório para testar no dispositivo**

Google Play Console → **Configurações** → **License testing** → adicione o e-mail da conta Google logada no dispositivo Android de teste.

> Use apenas **uma conta Google** no dispositivo — múltiplas contas causam falha nas compras.

**9. Rodar no dispositivo Android**

```bash
make run-android
```

Faça uma compra — o modal real do Google Play aparece. No Sandbox, assinaturas mensais renovam a cada 5 minutos.

---

## Checklist rápido

### Test Store (sem Apple/Google)

- [ ] Conta e projeto criados no RevenueCat
- [ ] App criado como **Test Store** — chave `test_xxx` colada
- [ ] Produtos, Entitlements e Offerings configurados no RC
- [ ] Webhook registrado no RC e testado (`200 OK`)
- [ ] Compra de teste ativa o entitlement corretamente

### iOS (App Store Connect)

- [ ] Apple Developer Program ativo (USD $99/ano)
- [ ] Paid Applications Agreement assinado
- [ ] Conta bancária validada no App Store Connect
- [ ] App criado no App Store Connect com Bundle ID correto
- [ ] Grupo de assinaturas criado com idioma configurado (sem isso os produtos ficam em "Missing Metadata")
- [ ] Assinaturas criadas com IDs idênticos ao RevenueCat, com preço, idioma e captura de tela preenchidos
- [ ] Status das assinaturas em **Pronto para envio**
- [ ] App criado no RC como **App Store** — chave `appl_xxx` atualizada nos arquivos
- [ ] Sandbox Tester criado em App Store Connect → Users and Access → Sandbox (e-mail sem conta Apple)
- [ ] Developer Mode ativo no iPhone (Ajustes → Privacidade e Segurança → Modo de Desenvolvedor)
- [ ] Conta Sandbox conectada no iPhone (Ajustes → Desenvolvedor → Conta Sandbox)
- [ ] Chave P8 configurada no RC
- [ ] Compra testada no iPhone físico

### Android (Google Play)

- [ ] Google Play Developer ativo (USD $25)
- [ ] Perfil de pagamento configurado
- [ ] App criado e publicado no track de Teste Interno
- [ ] Assinaturas criadas com IDs idênticos ao RevenueCat
- [ ] APIs ativadas no Google Cloud Console
- [ ] Service Account criada, JSON baixado e Service Account convidada no Google Play
- [ ] JSON da Service Account enviado ao RC — chave `goog_xxx` atualizada nos arquivos
- [ ] License Tester adicionado no Google Play Console
- [ ] Somente uma conta Google logada no dispositivo de teste
- [ ] Compra testada no dispositivo Android físico

---

## Erros comuns

**`INVALID_CREDENTIALS`** — tipo do app no RC e prefixo da chave não batem. `Test Store` exige chave `test_`, `App Store` exige `appl_`, `Google Play` exige `goog_`.

**Produtos não aparecem no paywall** — IDs dos produtos não são idênticos entre a loja e o RC, ou o Paid Applications Agreement não está assinado (iOS), ou o app não está publicado no track interno (Android).

**Sandbox retorna lista vazia (iOS)** — configuração de negócios incompleta em App Store Connect → Agreements, Tax, and Banking. Verifique: Paid Applications Agreement aceito, conta bancária cadastrada, formulários fiscais preenchidos, conformidades aceitas. Após completar tudo, aguarde 4 a 6 horas antes de testar.

Verifique com:

```bash
kasy doctor
```

O `kasy doctor` exibe uma seção **RevenueCat** automaticamente quando o projeto usa a feature. Exemplo de saída:

```
RevenueCat
  ✓ Chaves de API configuradas (iOS + Android)
  ⚠ Usando chaves Test Store (test_) — substitua por appl_ e goog_ para produção
  ✓ URL do webhook (cole no RevenueCat → Integrations → Webhooks):
     https://SEU_PROJECT_REF.supabase.co/functions/v1/revenuecat-webhook
```

> Para projetos Firebase, o `kasy doctor` indica onde encontrar a URL no Firebase Console em vez de exibi-la diretamente.
