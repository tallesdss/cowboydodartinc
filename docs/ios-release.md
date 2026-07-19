# Publicar no iOS (App Store)

## Pré-requisitos

- Conta [Apple Developer](https://developer.apple.com) (paga)
- App criado no [App Store Connect](https://appstoreconnect.apple.com) com o mesmo **Bundle ID** do projeto
- Mac com Xcode e Flutter instalados

## Configuração única

```bash
kasy ios configure
```

O comando abre os links da Apple, pede a chave API (`.p8`) e grava `.kasy/apple.env` (não vai para o Git).

## Assinatura no Xcode (obrigatório uma vez)

O Kasy remove o `DEVELOPMENT_TEAM` do template para você usar sua conta Apple.

1. Abra `ios/Runner.xcworkspace` no Xcode.
2. Target **Runner** → **Signing & Capabilities** → marque **Automatically manage signing** e escolha seu **Team**.

Confira com `kasy doctor` (seção Release iOS).

## Enviar nova versão

```bash
kasy ios release
```

Incrementa o build no `pubspec.yaml`, gera o IPA e envia direto para a App Store Connect — sem precisar abrir o Transporter. Se preferir enviar manualmente, use o app **Transporter** com o `.ipa` gerado em `build/ios/ipa/`.

Atalho: `make release-ios`

### Opções

- `kasy ios build` — só gera o IPA, sem enviar
- `kasy ios release --no-bump` — não incrementa o build
- `kasy ios release --version-name 1.0.1` — altera a versão visível

## Sem Mac?

Use build na nuvem: [codemagic-release.md](./codemagic-release.md) e `kasy codemagic configure` / `kasy codemagic release`.

## Verificar ambiente

```bash
kasy doctor
```
