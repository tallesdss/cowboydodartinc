import 'package:flutter/material.dart';

/// Compare paywall palette — cool slate canvas + blue accent (distinct from Solo).
///
/// Creative skin on purpose. Does **not** follow kit rebrand. Leave as shipped
/// unless redesigning this template. Theme-led paywall: [PaywallFactory.unlock].
abstract final class PaywallComparePalette {
  static const Color canvas = Color(0xFF0E1117);
  static const Color canvasDeep = Color(0xFF080A0F);
  static const Color card = Color(0xFF171C27);
  static const Color cardSelected = Color(0xFF1E2535);
  static const Color onCanvas = Color(0xFFF4F6FA);
  static const Color muted = Color(0xB3F4F6FA);
  static const Color subtle = Color(0xFF8B95A8);
  static const Color border = Color(0xFF2A3142);
  static const Color borderSelected = Color(0xFF5B8CFF);
  static const Color primary = Color(0xFF5B8CFF);
  static const Color primaryForeground = Color(0xFF081018);
  static const Color badge = Color(0xFFBAE6FD);
  static const Color badgeText = Color(0xFF0C4A6E);
  static const Color glow = Color(0x335B8CFF);
  static const Color checkFill = Color(0xFF5B8CFF);
  static const Color checkIcon = Color(0xFF081018);
  static const Color columnSelectedTop = Color(0xFF1A2740);
  static const Color columnSelectedBottom = Color(0xFF151D2E);
  static const Color columnDefaultTop = Color(0xFF171C27);
  static const Color columnDefaultBottom = Color(0xFF121722);
  static const Color matrixPremiumFill = Color(0xFF141D30);
  static const Color footerBar = Color(0xFF111620);
  static const Color closeScrim = Color(0x99080A0F);
}
