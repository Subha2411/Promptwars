import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgGradientStart = Color(0xFF0D1B2A);
  static const Color bgGradientEnd = Color(0xFF1B0A2E);
  
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFFB388FF);
  static const Color accentGreen = Color(0xFF69F0AE);
  static const Color accentYellow = Color(0xFFFFD740);
  static const Color accentRed = Color(0xFFFF5252);

  // Glass Colors
  static const Color glassWhite = Color(0x1EFFFFFF); // 12% opacity
  static const Color glassBorder = Color(0x33FFFFFF); // 20% opacity
  
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentPurple,
        surface: glassWhite,
        background: bgDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textSecondary),
      ),
    );
  }
}
