// Guardrail: flags raw radius/spacing numbers in screen/feature code that
// bypass the design system (KasyRadius / KasySpacing).
//
// Scope is deliberately `lib/features/**` only: `lib/components/**` and
// `lib/core/**` (theme tokens + shared low-level widgets) are the design
// system's own implementation — those legitimately hand-tune precise pixel
// geometry (a switch track, a badge's internal padding, an icon slot). It's
// screen-composition code that should always reach for a token instead of
// inventing its own number.
//
// Run: dart run scripts/check_design_tokens.dart
//
// Ratchet, not a hard zero: existing debt is tracked in
// scripts/design_tokens_baseline.txt (just a number). The check only fails
// if the count goes ABOVE that baseline — so today's 78 pre-existing spots
// don't red the build, but a new screen adding even one more raw value does.
// As debt gets cleaned up, lower the number in the baseline file to match.
//
// Escape hatch: append `// tokens-ignore` to a line to suppress it (use
// sparingly, for genuine one-off pixel nudges that don't belong on the scale).
import 'dart:io';

const String _scanDir = 'lib/features';
const String _baselineFile = 'scripts/design_tokens_baseline.txt';
const List<String> _excludedSuffixes = ['.g.dart', '.freezed.dart', '.mocks.dart'];
// Internal component-catalog/showcase screens, not real product screens —
// they deliberately size demo boxes ad hoc (e.g. "320px wide preview frame").
const List<String> _excludedFiles = [
  'home_components_preview_registry.dart',
  'home_components_preview_page.dart',
  'home_components_page.dart',
  'design_system_page.dart',
];
const String _ignoreMarker = 'tokens-ignore';

// Small optical nudges (1-3px, e.g. title-to-subtitle kerning fixes) aren't
// worth a token. The KasySpacing scale itself starts at xs = 4.
const int _minFlaggableSpacing = 4;

class Violation {
  final String file;
  final int line;
  final String kind;
  final String snippet;
  Violation(this.file, this.line, this.kind, this.snippet);
}

final RegExp _borderRadiusCircular =
    RegExp(r'BorderRadius\.circular\(\s*(-?\d+\.?\d*)\s*\)');
final RegExp _radiusConstAssign =
    RegExp(r'\bradius\w*\s*=\s*(-?\d+\.?\d*)\s*;', caseSensitive: false);
final RegExp _edgeInsetsCall = RegExp(
  r'EdgeInsets\.(all|symmetric|only|fromLTRB)\(([^;]*?)\)',
  dotAll: true,
);
final RegExp _sizedBoxCall = RegExp(
  r'SizedBox\(([^;]*?)\)',
  dotAll: true,
);
// SizedBox: only `height` is checked. `width` is excluded — it's just as
// often a fixed element size (icon slot, avatar diameter) as a layout gap,
// so it's too noisy to flag reliably.
final RegExp _sizedBoxHeightArg = RegExp(r'\bheight\s*:\s*(-?\d+\.?\d*)');
final RegExp _bareNumber = RegExp(r'^\s*(-?\d+\.?\d*)\s*$');

void main(List<String> args) {
  final Directory root = Directory(_scanDir);
  if (!root.existsSync()) {
    stderr.writeln('Run this from the Firebase/ project root ($_scanDir not found).');
    exit(2);
  }

  final List<Violation> violations = [];

  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final String path = entity.path.replaceAll('\\', '/');
    if (!path.endsWith('.dart')) continue;
    if (_excludedSuffixes.any(path.endsWith)) continue;
    if (_excludedFiles.any(path.endsWith)) continue;

    final String content = entity.readAsStringSync();
    final List<String> lines = content.split('\n');

    // BorderRadius.circular(<number>) — should be KasyRadius.*
    for (final m in _borderRadiusCircular.allMatches(content)) {
      _report(violations, path, content, m, 'raw BorderRadius.circular(${m.group(1)})');
    }

    // const double _fooRadius = 18; — a raw radius constant hiding behind a name
    for (final m in _radiusConstAssign.allMatches(content)) {
      _report(violations, path, content, m, 'raw radius constant (= ${m.group(1)})');
    }

    // EdgeInsets.*(...) with bare numeric args — should be KasySpacing.*
    for (final m in _edgeInsetsCall.allMatches(content)) {
      final String inner = m.group(2) ?? '';
      final bool hasKasy = inner.contains('Kasy');
      final List<String> parts = inner.split(',');
      for (final part in parts) {
        final String trimmed = part.trim();
        if (trimmed.isEmpty) continue;
        final String value = trimmed.contains(':')
            ? trimmed.split(':').last.trim()
            : trimmed;
        final RegExpMatch? bare = _bareNumber.firstMatch(value);
        if (bare == null) continue;
        final double n = double.parse(bare.group(1)!);
        if (n == 0) continue; // EdgeInsets.zero-equivalent, fine either way
        if (hasKasy && parts.length > 1) {
          // Mixed call (some Kasy tokens, some raw) — still flag the raw part.
        }
        _reportAt(violations, path, content, m.start, 'raw EdgeInsets value ($value)');
        break; // one flag per call site is enough signal
      }
    }

    // SizedBox(height: <number >= 4>) — should be KasySpacing.* (vertical
    // rhythm gap). `width` is intentionally not checked — see note above.
    for (final m in _sizedBoxCall.allMatches(content)) {
      final String inner = m.group(1) ?? '';
      for (final numMatch in _sizedBoxHeightArg.allMatches(inner)) {
        final double n = double.parse(numMatch.group(1)!);
        if (n.abs() < _minFlaggableSpacing) continue;
        _reportAt(violations, path, content, m.start, 'raw SizedBox gap (${numMatch.group(0)})');
        break;
      }
    }

    for (final v in violations.where((v) => v.file == path).toList()) {
      final String lineText = lines.length >= v.line ? lines[v.line - 1] : '';
      if (lineText.contains(_ignoreMarker)) {
        violations.remove(v);
      }
    }
  }

  final int baseline = _readBaseline();

  if (violations.isEmpty) {
    stdout.writeln('check_design_tokens: no raw radius/spacing literals found in $_scanDir.');
    if (baseline > 0) {
      stdout.writeln('Baseline is $baseline but count is 0 — lower it in $_baselineFile.');
    }
    exit(0);
  }

  violations.sort((a, b) => a.file == b.file ? a.line.compareTo(b.line) : a.file.compareTo(b.file));
  stdout.writeln('check_design_tokens: ${violations.length} raw value(s) bypassing KasyRadius/KasySpacing '
      '(baseline: $baseline):\n');
  for (final v in violations) {
    stdout.writeln('  ${v.file}:${v.line}  ${v.kind}');
    stdout.writeln('    ${v.snippet.trim()}');
  }
  stdout.writeln('\nUse KasyRadius.* / KasySpacing.* instead, or append "// $_ignoreMarker" if this is a deliberate one-off.');

  if (violations.length > baseline) {
    stdout.writeln('\n${violations.length - baseline} more than the baseline ($baseline) — new drift introduced, failing.');
    exit(1);
  }
  if (violations.length < baseline) {
    stdout.writeln('\nBelow baseline ($baseline) — nice, lower the number in $_baselineFile to lock in the improvement.');
  }
  exit(0);
}

int _readBaseline() {
  final File f = File(_baselineFile);
  if (!f.existsSync()) return 0;
  return int.tryParse(f.readAsStringSync().trim()) ?? 0;
}

void _report(List<Violation> out, String path, String content, Match m, String kind) {
  _reportAt(out, path, content, m.start, kind);
}

void _reportAt(List<Violation> out, String path, String content, int offset, String kind) {
  final int lineNumber = '\n'.allMatches(content.substring(0, offset)).length + 1;
  final int lineStart = content.lastIndexOf('\n', offset) + 1;
  int lineEnd = content.indexOf('\n', offset);
  if (lineEnd == -1) lineEnd = content.length;
  out.add(Violation(path, lineNumber, kind, content.substring(lineStart, lineEnd)));
}
