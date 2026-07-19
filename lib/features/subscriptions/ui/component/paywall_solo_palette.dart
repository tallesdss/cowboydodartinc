import 'package:flutter/material.dart';

/// Solo paywall palette — warm brown canvas + yellow CTA (reference-driven).
///
/// Creative skin on purpose. Does **not** follow kit rebrand. Leave as shipped
/// unless redesigning this template. Theme-led paywall: [PaywallFactory.unlock].
abstract final class PaywallSoloPalette {
  static const Color canvas = Color(0xFF2A1F18);
  static const Color canvasDeep = Color(0xFF1F1612);
  static const Color card = Color(0xFF4A382E);
  static const Color cardBorder = Color(0xFF5C4638);
  static const Color onCanvas = Color(0xFFF8F3EC);
  static const Color muted = Color(0xBFF8F3EC);
  static const Color pricePill = Color(0xFFE8D4BC);
  static const Color pricePillText = Color(0xFF1A140F);
  static const Color primary = Color(0xFFF5C842);
  static const Color primaryForeground = Color(0xFF1A140F);
  static const Color checkFill = Color(0xFFE8D4BC);
  static const Color checkIcon = Color(0xFF3A2D24);
}
