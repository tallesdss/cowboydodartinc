import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

/// Scroll behavior for kit surfaces.
///
/// - Removes the default overscroll **glow** that uses [ColorScheme.primary]
///   (often reads as a stray blue band when pulling a list at the top).
/// - Enables **drag-to-scroll with a mouse / trackpad** on web and desktop, so
///   scrollable surfaces behave like they do under touch. The Flutter default
///   omits the mouse from [dragDevices], which is why a `DraggableScrollableSheet`
///   bottom sheet (snap / scrollable / text-field sheets) could not be dragged
///   in a browser even though it worked natively.
class KasyKitScrollBehavior extends MaterialScrollBehavior {
  const KasyKitScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
