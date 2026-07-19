import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers for Kasy text styles.
///
/// Product stack: **Poppins** (single family for display + body/UI).
/// [GoogleFonts.poppins] embeds the weight in [TextStyle.fontFamily].
/// Calling [TextStyle.copyWith] with a different [FontWeight] updates the
/// property but keeps the old font file. Always use [withWeight] when
/// overriding weight on a themed style.
extension KasyTextStyle on TextStyle {
  TextStyle withWeight(FontWeight weight) {
    return GoogleFonts.poppins(
      textStyle: this,
      fontWeight: weight,
    );
  }
}
