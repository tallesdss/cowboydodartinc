// Kasy design-system guard-rail.
//
// Fails (exit 1) when a FEATURE SCREEN reaches around the design system and
// hardcodes a value that should come from a token / component. The design
// primitives themselves (lib/components, lib/core) are exempt — that is where
// the system is built, so raw values are expected there.
//
// This is intentionally a plain script, not a hidden dependency: read it, tune
// the lists below, or delete it. It enforces the project's *defaults*; it never
// locks anyone in.
//
// Run it locally or in CI:
//   dart run tool/design_check.dart
//
// Escape hatch for a deliberate one-off: put `// design-check: ignore` on the
// offending line (the reason should be obvious from a nearby comment).
//
// See DESIGN_SYSTEM.md for the tokens/roles to use instead.

import 'dart:io';

/// The guard-rail only scans FEATURE SCREENS ([_scanRoot]). The design system
/// itself (lib/components, lib/core) and the app bootstrap (lib/main.dart) are
/// the *implementation* of the system, so raw values are expected there and are
/// out of scope by construction.
const String _scanRoot = 'lib/features';

/// Path fragments that are exempt even inside the feature layer.
/// - admin: internal admin tooling (kept out of the product design pass).
/// - generated files: not authored by hand.
/// - showcase/mockups: deliberately render raw values to demo them.
/// - subscriptions: the paywall is mid-redesign; re-enable when it lands.
const List<String> _exemptPathFragments = <String>[
  '/admin/',
  'admin_card.dart',
  '.g.dart',
  '.freezed.dart',
  'home_components_preview_registry.dart',
  'home_components_preview_page.dart',
  'home_components_page.dart',
  'design_system_page.dart',
  'onboarding_module_mockups.dart',
  '/features/subscriptions/',
];

const String _ignoreMarker = '// design-check: ignore';

class _Rule {
  const _Rule(this.id, this.pattern, this.message);
  final String id;
  final RegExp pattern;
  final String message;

  /// Optional secondary token that must ALSO be on the line for the rule to
  /// fire (used to scope `size:` to Icon lines only).
  bool matches(String line) => pattern.hasMatch(line);
}

final List<_Rule> _rules = <_Rule>[
  _Rule(
    'raw-material',
    RegExp(r'\b(ElevatedButton|OutlinedButton|TextButton|AlertDialog|SnackBar)\s*\(|(?<![A-Za-z])Card\s*\('),
    'Use the Kasy component (KasyButton / showKasyConfirmDialog / showKasyToast '
        '/ KasyCard) instead of the raw Material widget.',
  ),
  _Rule(
    'hardcoded-font-size',
    RegExp(r'fontSize:\s*\d'),
    'Use a typography role (context.textTheme.* / KasyTextTheme.*) instead of a '
        'literal fontSize.',
  ),
  _Rule(
    'raw-color',
    // `Color(0x...)` literals, or `Colors.<named>` — but NOT `KasyColors.` (the
    // token class, hence the lookbehind) and NOT the transparent / white* /
    // black* helpers, which are the legitimate way to build scrims & overlays.
    RegExp(r'Color\(0x|(?<![A-Za-z])Colors\.(?!transparent\b)(?!white)(?!black)[A-Za-z]'),
    'Use a colour token (context.colors.*) instead of a raw Color/Colors value.',
  ),
  _Rule(
    'hardcoded-radius',
    // A numeric literal right after `circular(` — catches BorderRadius.circular(16),
    // Radius.circular(8) and the only/vertical/horizontal forms (they nest a
    // Radius.circular). `circular(KasyRadius.lg)` starts with a letter, so it
    // passes; `circular(size / 2)` likewise (calibrated, not a token miss).
    RegExp(r'\bcircular\(\s*\d'),
    'Use a KasyRadius.* token instead of a literal corner radius.',
  ),
];

// The icon rule needs two signals on the same line, so it is handled separately.
final RegExp _iconCall = RegExp(r'\bIcon\s*\(');
final RegExp _numericSize = RegExp(r'size:\s*\d');

bool _isExempt(String path) =>
    _exemptPathFragments.any((String frag) => path.contains(frag));

void main() {
  final Directory libDir = Directory(_scanRoot);
  if (!libDir.existsSync()) {
    stderr.writeln('design_check: run me from the package root (no $_scanRoot here).');
    exit(2);
  }

  final List<String> violations = <String>[];
  int scanned = 0;

  for (final FileSystemEntity entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final String path = entity.path.replaceAll(r'\', '/');
    if (_isExempt('/$path')) continue;
    scanned++;

    final List<String> lines = entity.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (line.contains(_ignoreMarker)) continue;
      final String code = _stripComment(line);
      if (code.trim().isEmpty) continue;

      for (final _Rule rule in _rules) {
        if (rule.matches(code)) {
          violations.add(_format(path, i + 1, rule.id, rule.message, line));
        }
      }
      if (_iconCall.hasMatch(code) && _numericSize.hasMatch(code)) {
        violations.add(_format(
          path,
          i + 1,
          'hardcoded-icon-size',
          'Use a KasyIconSize.* token instead of a literal Icon size.',
          line,
        ));
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('design_check: OK ($scanned feature files clean).');
    exit(0);
  }

  stdout.writeln('design_check: ${violations.length} violation(s) found.\n');
  stdout.writeln(violations.join('\n\n'));
  stdout.writeln(
    '\nFix by using a token/role/component (see DESIGN_SYSTEM.md), or mark a '
    'deliberate exception with `$_ignoreMarker` on the line.',
  );
  exit(1);
}

/// Drops an end-of-line `//` comment so rules don't match commented-out code or
/// doc text (keeps string literals intact enough for these coarse checks).
String _stripComment(String line) {
  final int idx = line.indexOf('//');
  return idx == -1 ? line : line.substring(0, idx);
}

String _format(String path, int line, String id, String message, String src) {
  return '  $path:$line  [$id]\n    ${src.trim()}\n    → $message';
}
