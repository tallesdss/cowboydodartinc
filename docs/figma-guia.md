# Figma: rebrand e telas

O Kasy entrega o design system como arquivo **Figma** na Community. Você duplica
para sua conta, edita as cores e a fonte, e a IA do editor aplica no Flutter.

**Link para duplicar:**
https://www.figma.com/design/S083trj2ctFrEFNjcavtpC/Kasy-Design-System/duplicate

---

## O que vem no projeto

Depois de `kasy new`, você tem:

| Arquivo | O que é |
| ------- | ------- |
| `docs/figma-guia.md` | Este guia offline no idioma do projeto |
| `docs/figma-workflow.md` | Regras para a IA (inglês) |

O design system **não** é copiado como arquivo local. Use o link acima.

Telas do **seu** produto ficam em outro arquivo Figma que você cria, por exemplo
`Meu App`.

---

## Duplicar o design system

1. Abra o link de duplicate acima (precisa de conta Figma gratuita).
2. Clique para salvar nos seus **Drafts**.
3. Abra o arquivo duplicado no Figma desktop ou web.

---

## Rebrand em 4 passos

### 1. Abrir Variables

No Figma: **Local variables** (ícone de losango) → coleção **Kasy Colors**.

Modos **Light** e **Dark**. A ordem das cores segue o app: Accent, Default,
Success, Warning, Danger, Foreground, Background, Surface, Form field,
Separator, Other.

### 2. Mudar sua marca

- **brand/primary/base:** cor principal (botões CTA). No Dart:
  `context.colors.primary`. Exemplo kit: light `#0553B1`, dark `#2563EB`
  (bindado no Sign In do Figma master). Links no dark usam `text/link`
  (`foregroundLink`, `#4BA3FF`). Sem `brand/secondary`.
- **color/background/background** ou **background/base:** fundo de tela
  (também afeta o splash). No Dart: `context.colors.background`.
- **color/foreground/foreground** ou **foreground/base:** texto principal.
- Fonte do produto: **Poppins** (família única: Display, headings, body/UI).
  Figma e o app usam a mesma família. Para migrar um arquivo antigo (Inter/Nunito),
  rode o plugin **Kasy Poppins Sync** (`tools/kasy-figma-poppins-sync/`).
  Para regenerar tokens do zero, use **Kasy DS Generator** (`tools/kasy-figma-generator/`).

### 3. Colar o prompt na IA

Abra a pasta do projeto no Cursor e cole (substitua a URL pelo seu arquivo
duplicado):

```
Leia AGENTS.md e docs/figma-workflow.md.

Meu arquivo Figma: [COLE A URL DO SEU ARQUIVO DUPLICADO]
Use Figma MCP get_variable_defs na página 01 Tokens.

Sincronize TODAS as cores em lib/core/theme/colors.dart
(KasyColors.light() e KasyColors.dark()), não só o accent.

Se o fundo mudou, atualize a cor do splash no pubspec.yaml.

Confira na tela Design System do app (claro e escuro).
flutter analyze sem erros.
```

### 4. Conferir no app

```bash
kasy run --web
```

Vá em **Home → Design System**. Alterne tema claro/escuro em Configurações.

Só crie telas novas **depois** que o rebrand estiver certo.

---

## Ícone, logo e favicon

Depois de `kasy new`, a marca visual fica em `assets/branding/`:

| Arquivo | Uso | Comando |
| ------- | --- | ------- |
| `app-icon.png` | Ícone do app (iOS/Android) | `kasy icon --image ...` |
| `logo-light.png` / `logo-dark.png` | Logo no app (login, sidebar) | `kasy splash` (sincroniza) ou troque o arquivo |
| `splash-logo-light.png` / `splash-logo-dark.png` | Splash nativa | `kasy splash --light ... --dark ...` |
| `favicon.png` | Aba do browser / PWA | `kasy favicon --image ...` |

Manual: substitua o PNG e rode `dart run flutter_launcher_icons` (ícone/favicon)
ou `dart run flutter_native_splash:create` (splash). Docs:
[Ícone](https://kasy.dev/docs/personalizacao/icone),
[Splash](https://kasy.dev/docs/personalizacao/splash),
[Favicon](https://kasy.dev/docs/personalizacao/favicon).

---

## Criar uma tela nova

### 1. Desenhar

Crie um arquivo Figma `Meu App`. Use as **mesmas variables** do design system.

### 2. Prompt para a IA

```
Leia docs/figma-workflow.md.
Meu arquivo de telas: [URL FIGMA]
Implemente a tela [NOME DO FRAME].
Fiel ao layout, funcional (botões, campos, navegação).
Componentes Kasy, tokens, i18n (pt, en, es).
Se alguma cor não existir no design system, avise antes de codar.
flutter analyze limpo.
```

### 3. Testar

```bash
kasy run --web
```

---

## Erros comuns

| Problema | O que fazer |
| -------- | ----------- |
| App continua azul | Peça sync de **todas** as cores, não só accent |
| IA usou Material cru | Peça `KasyButton`, `KasyCard`, `KasyTextField` |
| Cor diferente no mockup | Primeiro entra no design system, depois no código |
| Texto fixo no Dart | Tudo via i18n |

---

## Resumo

1. **Rebrand** no Figma (variables) → IA → `lib/core/theme/`.
2. **Telas** no arquivo de app → IA → fiel e funcional.
3. **Cor fora do DS** → IA avisa, não hardcode.

Veja também [Cores](https://kasy.dev/docs/personalizacao/cores) e
[Design System](https://kasy.dev/docs/conceitos/design-system).
