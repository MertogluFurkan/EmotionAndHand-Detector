import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Ana renkler — mor/pembe gradient
  static const primary = Color(0xFF7C3AED);       // deep purple
  static const primaryLight = Color(0xFF9F67FF);
  static const secondary = Color(0xFFEC4899);      // pink
  static const accent = Color(0xFF06B6D4);         // cyan

  // Arka plan
  static const bgDark = Color(0xFF0F0A1E);
  static const bgCard = Color(0xFF1A1030);
  static const bgCardLight = Color(0xFF231845);

  // Duygu renkleri
  static const emotionHappy = Color(0xFFF59E0B);
  static const emotionSad = Color(0xFF3B82F6);
  static const emotionAngry = Color(0xFFEF4444);
  static const emotionFear = Color(0xFF8B5CF6);
  static const emotionSurprise = Color(0xFFF97316);
  static const emotionDisgust = Color(0xFF10B981);
  static const emotionNeutral = Color(0xFF6B7280);

  // Cilt tip renkleri
  static const skinOily = Color(0xFFF59E0B);
  static const skinDry = Color(0xFF60A5FA);
  static const skinCombination = Color(0xFF34D399);
  static const skinNormal = Color(0xFFA78BFA);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3A8D4);
  static const divider = Color(0xFF2D1F5E);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF4F1D96), Color(0xFF1E0A4A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgCard, bgCardLight],
  );

  static Color emotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return emotionHappy;
      case 'sad':
        return emotionSad;
      case 'angry':
        return emotionAngry;
      case 'fear':
        return emotionFear;
      case 'surprise':
        return emotionSurprise;
      case 'disgust':
        return emotionDisgust;
      default:
        return emotionNeutral;
    }
  }

  static Color skinTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'oily':
        return skinOily;
      case 'dry':
        return skinDry;
      case 'combination':
        return skinCombination;
      default:
        return skinNormal;
    }
  }
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
