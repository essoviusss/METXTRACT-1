import 'package:flutter/material.dart';

class ColorUtils {
  static const Color background = Colors.white;
  static const Color lightPurple = Color(0xFFD1B2FF);
  static const Color mediumPurple = Color(0xFF8959FF);
  static const Color darkPurple = Color(0xFF536878);
  static const Color gray1 = Color(0xFF434b54);
  static const Color gray2 = Color(0xFF6e7f80);
  static const Color docText = Color.fromARGB(255, 68, 132, 228);
  //0xFF261342
  // sample
  static const Color p1 = Color(0xFF2e145d);
  static const Color p2 = Color(0xFF1c1854);
  static const Color p3 = Color(0xFF0c1444);
  static const Color p4 = Color(0xFF05122d);

  static List<Color> getPurplePalette() {
    return [
      background,
      lightPurple,
      mediumPurple,
      darkPurple,
      gray1,
      gray2,
      docText,
      p1,
      p2,
      p3,
      p4,
    ];
  }
}
