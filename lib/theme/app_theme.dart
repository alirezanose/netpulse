import 'package:flutter/material.dart';

class AppTheme {
  // Beatles 'White Album' Minimalist Palette
  static const Color background = Color(0xFFFAFAFA); // Crisp off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceMuted = Color(0xFFF4F4F5); // Soft zinc
  static const Color border = Color(0xFFE4E4E7); // Subtle hairline border
  static const Color borderDark = Color(0xFFD4D4D8);

  static const Color primary = Color(0xFF18181B); // Pitch charcoal / matte black
  static const Color primaryLight = Color(0xFF27272A);
  static const Color accent = Color(0xFF0D9488); // Subtle teal for active signals
  static const Color success = Color(0xFF10B981); // Soft emerald
  static const Color warning = Color(0xFFF59E0B); // Soft amber
  static const Color danger = Color(0xFFEF4444); // Soft crimson

  static const Color textPrimary = Color(0xFF09090B); // High contrast black
  static const Color textSecondary = Color(0xFF52525B); // Neutral gray
  static const Color textMuted = Color(0xFFA1A1AA); // Light muted zinc

  static ThemeData get whiteAlbumTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
      ),
    );
  }
}
