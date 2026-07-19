import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Makes focus rings keyboard-only — the web's `:focus-visible` behaviour.
///
/// Flutter's default [FocusHighlightStrategy.automatic] only hides focus rings
/// for *touch*; on desktop a mouse click keeps them in "traditional" mode, so a
/// ring raised by Tab navigation never clears once the user grabs the mouse.
/// This wraps the app and flips the strategy by input type:
///   - a navigation key (Tab / arrows / Home / End / Page Up·Down) shows rings;
///   - any pointer press hides them, and — when the user was mid keyboard
///     navigation — also drops focus, so the next Tab restarts from the top of
///     the traversal (skip link → sidebar → content) instead of resuming
///     wherever the ring happened to be.
///
/// Plain typing does NOT turn rings on (only navigation keys do), so editing a
/// text field with the mouse stays ring-free. Uses a global pointer route so it
/// catches clicks anywhere, including empty areas with no hit target.
class FocusVisibility extends StatefulWidget {
  const FocusVisibility({super.key, required this.child});

  final Widget child;

  @override
  State<FocusVisibility> createState() => _FocusVisibilityState();
}

class _FocusVisibilityState extends State<FocusVisibility> {
  static final Set<LogicalKeyboardKey> _navigationKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.tab,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
  };

  @override
  void initState() {
    super.initState();
    // Start ring-free; the first navigation key turns them on.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    HardwareKeyboard.instance.addHandler(_handleKey);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointer);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointer);
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && _navigationKeys.contains(event.logicalKey)) {
      _setStrategy(FocusHighlightStrategy.alwaysTraditional);
    }
    return false; // observe only — never consume the event
  }

  void _handlePointer(PointerEvent event) {
    if (event is! PointerDownEvent) {
      return;
    }
    final FocusManager fm = FocusManager.instance;
    final bool wasKeyboardNav =
        fm.highlightMode == FocusHighlightMode.traditional;
    _setStrategy(FocusHighlightStrategy.alwaysTouch);
    // Only reset focus when leaving keyboard navigation; a normal click (e.g.
    // into a text field) then keeps the focus it's about to request.
    if (wasKeyboardNav) {
      fm.primaryFocus?.unfocus();
    }
  }

  void _setStrategy(FocusHighlightStrategy strategy) {
    if (FocusManager.instance.highlightStrategy != strategy) {
      FocusManager.instance.highlightStrategy = strategy;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
