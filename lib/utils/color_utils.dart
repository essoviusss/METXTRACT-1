import 'package:flutter/material.dart';

class ColorUtils {
  static const Color background = Colors.white;
  static const Color lightPurple = Color(0xFFD1B2FF);
  static const Color mediumPurple = Color(0xFF8959FF);
  static const Color darkPurple = Color(0xFF5D37BD);

  static List<Color> getPurplePalette() {
    return [background, lightPurple, mediumPurple, darkPurple];
  }
}
