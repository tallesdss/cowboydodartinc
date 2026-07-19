import 'package:cowboydodartinc/components/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// The per-screen desktop bar override is just data: a screen transforms the
/// shell default into its own [KasyAppBarConfig]. These lock that logic.
void main() {
  group('KasyAppBarConfig', () {
    test('bare config shows every element (mirrors the shell default)', () {
      const KasyAppBarConfig c = KasyAppBarConfig();
      expect(c.showSearch, isTrue);
      expect(c.showThemeToggle, isTrue);
      expect(c.showNotifications, isTrue);
      expect(c.showCreate, isTrue);
      expect(c.showAvatar, isTrue);
    });

    test('only() shows just the listed elements but keeps their wiring', () {
      void bell() {}
      void toggle() {}
      final KasyAppBarConfig base = KasyAppBarConfig(
        onNotifications: bell,
        onToggleTheme: toggle,
      );

      final KasyAppBarConfig cfg = base.only(notifications: true, themeToggle: true);

      expect(cfg.showNotifications, isTrue);
      expect(cfg.showThemeToggle, isTrue);
      expect(cfg.showSearch, isFalse);
      expect(cfg.showCreate, isFalse);
      expect(cfg.showAvatar, isFalse);
      // The shell's bell/theme callbacks survive the override.
      expect(cfg.onNotifications, same(bell));
      expect(cfg.onToggleTheme, same(toggle));
    });

    test('search preset = search + theme only', () {
      const KasyAppBarConfig cfg = KasyAppBarConfig.search();
      expect(cfg.showSearch, isTrue);
      expect(cfg.showThemeToggle, isTrue);
      expect(cfg.showNotifications, isFalse);
      expect(cfg.showCreate, isFalse);
      expect(cfg.showAvatar, isFalse);
    });

    test('minimal preset = theme toggle only', () {
      const KasyAppBarConfig cfg = KasyAppBarConfig.minimal();
      expect(cfg.showThemeToggle, isTrue);
      expect(cfg.showSearch, isFalse);
      expect(cfg.showNotifications, isFalse);
      expect(cfg.showCreate, isFalse);
      expect(cfg.showAvatar, isFalse);
    });

    test('copyWith with no changes is value-equal (no churn on the bar)', () {
      const KasyAppBarConfig a = KasyAppBarConfig();
      final KasyAppBarConfig b = a.copyWith();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes only the named field', () {
      const KasyAppBarConfig a = KasyAppBarConfig();
      final KasyAppBarConfig b = a.copyWith(showSearch: false);
      expect(b.showSearch, isFalse);
      expect(b.showCreate, isTrue);
      expect(a == b, isFalse);
    });
  });
}
