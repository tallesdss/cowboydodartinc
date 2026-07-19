# Transições de navegação (Kasy Kit)

## Visão geral

As transições de tela são centralizadas em `lib/core/navigation/`.
**Android, iOS e Web usam a mesma animação** — nada de `Zoom` no Android e `Cupertino` no iOS.

## Mudar o padrão do app inteiro

Edite [`lib/core/navigation/kasy_navigation_config.dart`](../lib/core/navigation/kasy_navigation_config.dart):

```dart
class KasyNavigationConfig {
  static KasyTransitionKind push = KasyTransitionKind.fade; // mude aqui
  static const Duration duration = Duration(milliseconds: 250);
  // ...
}
```

| Campo da config | Usado para |
|-----------------|------------|
| `push` | Maioria das rotas GoRouter (`kasyTransitionPage` sem override) |
| `replace` | Reservado para navegação estilo replace |
| `authPeer` | Login ↔ cadastro |
| `bottomTab` | Abas do menu inferior (Bart) |
| `onboardingStep` | Navegador interno do onboarding |

## Adicionar uma nova rota GoRouter

Use `pageBuilder`, não `builder`:

```dart
GoRoute(
  path: '/my_feature',
  pageBuilder: (context, state) => kasyTransitionPage(
    key: state.pageKey,
    child: const MyFeaturePage(),
  ),
),
```

### Override para uma rota só

```dart
pageBuilder: (context, state) => kasyTransitionPage(
  key: state.pageKey,
  transition: KasyTransitionKind.none,
  child: const MyFeaturePage(),
),
```

## `Navigator.push` legado

Use `KasyMaterialPageRoute` no lugar de `MaterialPageRoute`:

```dart
Navigator.of(context).push(
  KasyMaterialPageRoute(builder: (_) => const MyPage()),
);
```

## Tipos de transição

| Tipo | Descrição |
|------|-----------|
| `fade` | Crossfade (padrão do push) |
| `fadeThrough` | Fade-through do Material |
| `sharedAxisScaled` | Profundidade / escala |
| `sharedAxisHorizontal` | Shared axis horizontal |
| `none` | Sem animação |

## O que NÃO é coberto

- Diálogos (`showAppDialog`, `showGeneralDialog`)
- Bottom sheets (`showModalBottomSheet`)
- Animações internas de widget (`AnimatedSwitcher`, etc.)

## Tema de fallback

O [`universal_theme.dart`](../lib/core/theme/universal_theme.dart) usa `kasyPageTransitionsTheme` para que qualquer `MaterialPageRoute` restante ainda faça fade de forma consistente. Prefira `kasyTransitionPage` / `KasyMaterialPageRoute` em código novo.
