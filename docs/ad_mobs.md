# Anúncios (AdMob)

O módulo de anúncios embrulha o **Google AdMob** (`google_mobile_ads`) e suporta os
quatro formatos do AdMob: **banner, interstitial, rewarded e rewarded-interstitial**.

- **Só no nativo.** O AdMob não tem SDK web, então na web toda chamada de anúncio é
  um no-op silencioso e o `KasyAdBanner` não renderiza nada. Isso é automático —
  é sempre seguro usar código de anúncios em widgets compartilhados.
- **Funciona sem configurar nada.** Até você definir ids reais, builds de debug
  mostram os **anúncios de teste** oficiais do Google. Builds de release nunca
  mostram anúncios de teste.
- **Premium = sem anúncios.** Usuários com assinatura ativa não veem os formatos
  automáticos (banner + interstitial). Os formatos recompensados continuam
  disponíveis, porque o usuário escolhe assisti-los.

> ⚠ Você só consegue criar ad unit ids reais depois que o app estiver registrado no
> console do AdMob (e normalmente publicado). Publique uma primeira versão sem ids
> reais (anúncios de teste) e adicione-os depois.

## Ligar / desligar

Anúncios vêm no `kasy new` (modo Rápido). Para adicionar num projeto existente:

```
kasy add ads
```

O comando pergunta seus **app ids** do AdMob (opcional — em branco mantém os ids de
teste), configura o nativo, a dependência `google_mobile_ads` e a flag `withAds`.

Defina os ids depois a qualquer momento com `kasy configure` (aparece uma seção
"Anúncios (AdMob)").

## Configuração

Existem dois tipos de valor:

1. **App id** (um por plataforma) — nativo, em tempo de build. Fica em
   `android/app/src/main/res/values/strings.xml` (`admob_app_id`) e em
   `ios/Runner/Info.plist` (`GADApplicationIdentifier`). Configure com
   `kasy configure` / `kasy add ads`. O SDK exige — o app crasha na abertura sem um
   app id válido (o template já vem com o app id de teste do Google).
2. **Ad unit ids** (um por formato, por plataforma) — env do cliente, lidos em
   runtime do `.env`:

```
ADMOB_ANDROID_BANNER=
ADMOB_IOS_BANNER=
ADMOB_ANDROID_INTERSTITIAL=
ADMOB_IOS_INTERSTITIAL=
ADMOB_ANDROID_REWARDED=
ADMOB_IOS_REWARDED=
ADMOB_ANDROID_REWARDED_INTERSTITIAL=
ADMOB_IOS_REWARDED_INTERSTITIAL=
```

Deixe em branco para usar anúncios de teste durante o desenvolvimento; preencha os
ids reais antes de um build de release.

## Usando anúncios no seu app

Tudo passa pelo `googleAdsProvider`
(`lib/core/ads/ads_provider.dart`). O SDK já é inicializado para você no `main.dart`.

### Banner

Solte o widget em qualquer lugar — ele lê o ad unit certo, se esconde para usuários
premium e não renderiza nada na web:

```dart
import 'package:cowboydodartinc/core/ads/widgets/kasy_ad_banner.dart';

const KasyAdBanner();                          // banner padrão
const KasyAdBanner(size: KasyAdBannerSize.mediumRectangle);
```

### Interstitial

```dart
final ads = ref.read(googleAdsProvider.notifier);

// Mostra respeitando um cooldown, pra não bombardear o usuário (padrão 50s):
await ads.showInterstitialIfElapsed();

// Ou força um:
await ads.showInterstitial();
```

### Rewarded / Rewarded-interstitial

O usuário assiste um anúncio e ganha uma recompensa. A recompensa também é
verificada no servidor (veja SSV abaixo) — nunca conceda nada valioso só pelo
callback do cliente.

```dart
await ads.showRewarded(
  onReward: (reward) {
    // Só UI otimista; a concessão real é trabalho do servidor (SSV).
    debugPrint('Earned ${reward.amount} ${reward.type}');
  },
);

await ads.showRewardedInterstitial(onReward: (reward) { /* … */ });
```

## Verificação no servidor (SSV) — recompensas seguras

Para os formatos recompensados, o AdMob chama **o seu backend** para confirmar que o
usuário realmente assistiu ao anúncio, e aí o seu backend concede a recompensa. É a
única parte dos anúncios que toca o servidor, e é o que torna as recompensas à prova
de fraude.

O app já envia o id do usuário logado (`setServerSideOptions`), então o seu endpoint
sabe a quem creditar. Você só precisa fazer o deploy do endpoint e configurar a URL
dele no console do AdMob (em cada ad unit recompensado → SSV callback).

| Backend | Endpoint | Referência |
|---|---|---|
| Firebase | Cloud Function `ads-verifyAdReward` | `functions/src/ads/ads_functions.ts` |
| Supabase | Edge Function `verify-ad-reward` | + SQL `grant_ad_reward()` (migration) |
| API (seu servidor) | você implementa `GET /ads/verify-reward` | contrato no README do API |

Os três verificam a assinatura ECDSA contra as chaves públicas do Google
(`https://gstatic.com/admob/reward/verifier-keys.json`) e concedem a recompensa de
forma idempotente (chaveada por `transaction_id`). A concessão em si (moedas, vidas,
passe sem anúncios…) é um hook claramente marcado que você customiza.

Nenhum secret é necessário — a verificação usa as chaves públicas do Google.

## Removendo anúncios

`kasy remove ads` (ou não selecionar a feature) remove a dependência, o código de
`lib/core/ads`, a config nativa e a flag `withAds`.
