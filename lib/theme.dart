import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SanrioColors {
  // Pastel colors
  static const pastelPink = Color(0xFFFFE1E6);
  static const pastelMint = Color(0xFFE1F5E1);
  static const pastelBlue = Color(0xFFE1F0FF);
  static const pastelYellow = Color(0xFFFFF8E1);
  static const pastelLavender = Color(0xFFF0E1FF);
  
  // Checklist colors
  static const checklistDefault = Color(0xFFD2EDFF);
  static const checklistCompleted = Color(0xFF0099FF);
  
  // Main colors
  static const softPink = Color(0xFFFFB3D9);
  static const brightPink = Color(0xFFFF69B4);
  static const mintGreen = Color(0xFF98FB98);
  static const babyBlue = Color(0xFFADD8E6);
  static const softYellow = Color(0xFFFFFFCC);
  
  // Text colors
  static const darkText = Color(0xFF4A4A4A);
  static const lightText = Color(0xFF7A7A7A);
  
  // Surface colors
  static const surface = Color(0xFFFFFBFF);
  static const surfaceContainer = Color(0xFFF8F4FF);
  
  // Shadow color
  static const lightShadow = Color(0xFF000000);
}

class LightModeColors {
  static const lightPrimary = SanrioColors.brightPink;
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = SanrioColors.pastelPink;
  static const lightOnPrimaryContainer = SanrioColors.darkText;
  static const lightSecondary = SanrioColors.babyBlue;
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightTertiary = SanrioColors.mintGreen;
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFFF6B6B);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFE1E1);
  static const lightOnErrorContainer = Color(0xFF8B0000);
  static const lightInversePrimary = SanrioColors.softPink;
  static const lightShadow = Color(0x1A000000);
  static const lightSurface = SanrioColors.surface;
  static const lightOnSurface = SanrioColors.darkText;
  static const lightAppBarBackground = SanrioColors.pastelPink;
}


class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.pacifico(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
      color: SanrioColors.darkText,
    ),
    displayMedium: GoogleFonts.pacifico(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
      color: SanrioColors.darkText,
    ),
    displaySmall: GoogleFonts.pacifico(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
      color: SanrioColors.darkText,
    ),
    headlineLarge: GoogleFonts.pacifico(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
      color: SanrioColors.darkText,
    ),
    headlineMedium: GoogleFonts.pacifico(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    headlineSmall: GoogleFonts.pacifico(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
      color: SanrioColors.darkText,
    ),
    titleLarge: GoogleFonts.pacifico(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    titleMedium: GoogleFonts.pacifico(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    titleSmall: GoogleFonts.pacifico(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    labelLarge: GoogleFonts.comfortaa(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    labelMedium: GoogleFonts.comfortaa(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    labelSmall: GoogleFonts.comfortaa(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      color: SanrioColors.darkText,
    ),
    bodyLarge: GoogleFonts.comfortaa(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
      color: SanrioColors.darkText,
    ),
    bodyMedium: GoogleFonts.comfortaa(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
      color: SanrioColors.darkText,
    ),
    bodySmall: GoogleFonts.comfortaa(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
      color: SanrioColors.lightText,
    ),
  ),
);

ThemeData get darkTheme => lightTheme;
