# Publicar na nuvem com Codemagic (sem Mac)

Publica **iOS** e **Android** pela nuvem do Codemagic. Cada plataforma tem seu
próprio workflow, então você envia separado ou os dois juntos.

Alguns passos a **CLI faz por você**; outros são **manuais**, feitos uma vez no
painel do Codemagic ou no arquivo `codemagic.yaml`. Cada título abaixo diz qual é qual.

## Pré-requisitos

- Conta [Codemagic](https://codemagic.io)
- Repositório Git conectado ao Codemagic
- iOS: conta Apple Developer + app no App Store Connect
- Android: app no Google Play Console + keystore de assinatura

## 1. Adicionar CI ao projeto — a CLI cria o arquivo

```bash
kasy add ci
```

Isso cria o `codemagic.yaml` na raiz do projeto (workflows `ios-workflow` e
`android-workflow`).

## 2. Configurar no painel Codemagic — manual, uma vez

Estes itens são secretos e só podem ser feitos no painel — uma vez:

1. Abra [codemagic.io/apps](https://codemagic.io/apps) e **conecte o repositório**.
2. **iOS** — *Integrations → App Store Connect*: conecte a chave da Apple. No
   `codemagic.yaml`, o nome dela vai em `integrations: app_store_connect:`.
3. **Android** — *Code signing identities → Android keystores*: suba o keystore
   com o **Reference name** `keystore_reference` (o mesmo usado no `codemagic.yaml`).
4. **Android** — suba o JSON da **service account do Google Play** como variável
   secreta `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` (grupo `google_play`).

> As **chaves do app** (RevenueCat, backend, etc.) **não** precisam ser
> preenchidas no painel: o `kasy codemagic release` as envia automaticamente a
> partir do seu `.env`. Se preferir disparar pelo painel/push, aí sim cadastre-as
> nos grupos de variáveis.

## 3. Ajustar 2 campos no `codemagic.yaml` — manual, uma vez

O arquivo já marca esses pontos com um comentário `<-- Put your...`:

- **`publishing.app_store_connect.beta_groups`** (iOS) — troque `kasy` pelo nome
  de um grupo de testers que você cria no TestFlight (App Store Connect → seu
  app → TestFlight → Grupos). Sem isso o build sobe, mas ninguém recebe convite.
- **`publishing.email.recipients`** (iOS e Android) — coloque seu e-mail, ou
  apague a seção `email:` inteira se não quiser notificação.

## 4. Configurar no terminal — a CLI conduz, uma vez

```bash
kasy codemagic configure
```

Você só cola o token da API quando o wizard pedir; o resto é automático — ele
abre a página do **token da API** (Settings → Codemagic API), valida o token e
**lista os seus apps** para você escolher — sem digitar IDs. Salva tudo em
`.kasy/codemagic.env` (não versionado).

## 5. Disparar build — a CLI faz o resto

```bash
kasy codemagic release            # iOS + Android
kasy codemagic release --ios      # só iOS
kasy codemagic release --android  # só Android
```

O comando lê o seu `.env` e leva as chaves de produção (incluindo a chave de
produção do RevenueCat, `appl_`/`goog_`) junto no disparo. Um passo do
`codemagic.yaml` recria o `.env` na nuvem antes de compilar, então o build sai
com as chaves certas. Conforme o `codemagic.yaml`, o iOS vai para o TestFlight e
o Android para o track configurado (`internal` por padrão).

> **Android fica como rascunho.** O `codemagic.yaml` sobe com
> `submit_as_draft: true` — o build chega no track interno, mas você ainda
> precisa abrir o Play Console → Testes internos → Revisar release → Iniciar
> lançamento pra liberar de fato aos testadores.

## Status do build

```bash
kasy codemagic status <buildId>
```

## Posso usar o Mac e o Codemagic ao mesmo tempo?

Pode. São dois caminhos para a mesma loja, não conflitam. O número do build é
calculado pela própria nuvem (último na loja + 1), então dificilmente colide.
No dia a dia, escolha um caminho principal.

## Mac local

Se tiver Mac: veja [ios-release.md](./ios-release.md) e `kasy ios release`.
