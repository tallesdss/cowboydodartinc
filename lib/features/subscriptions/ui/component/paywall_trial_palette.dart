import 'package:flutter/material.dart';

/// Trial paywall palette — black canvas + purple accent (reference-driven).
///
/// Creative skin on purpose. Does **not** follow kit rebrand. Leave as shipped
/// unless redesigning this template. Theme-led paywall: [PaywallFactory.unlock].
abstract final class PaywallTrialPalette {
  static const Color canvas = Color(0xFF000000);
  static const Color canvasDeep = Color(0xFF000000);
  static const Color onCanvas = Color(0xFFFFFFFF);
  static const Color muted = Color(0xB3FFFFFF);
  static const Color subtle = Color(0xFF9CA3AF);
  static const Color primary = Color(0xFF7C6CFF);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color checkFill = Color(0xFF7C6CFF);
  static const Color checkIcon = Color(0xFFFFFFFF);
  static const Color toggleTrackOff = Color(0xFF3A3A3C);
  static const Color closeScrim = Color(0x99000000);
}
