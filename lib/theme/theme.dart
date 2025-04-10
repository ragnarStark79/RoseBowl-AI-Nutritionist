import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF007AFF); // iOS blue primary
  static const Color primaryDark = Color(0xFF0062CC); // Darker shade
  static const Color accent = Color(0xFF34C759); // iOS green

  // Background colors
  static const Color background = Color(0xFFF2F2F7); // Light background
  static const Color darkBackground = Color(0xFF1C1C1E); // Dark background

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF); // Light surface
  static const Color darkSurface = Color(0xFF2C2C2E); // Dark surface

  // Secondary surfaces
  static const Color secondarySurface = Color(0xFFE5E5EA); // Light secondary
  static const Color darkSecondarySurface = Color(0xFF3A3A3C); // Dark secondary

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);

  // Dark mode text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAEAEB2);

  // Message colors
  static const Color userBubble = Color(0xFF007AFF); // User message bubble
  static const Color botBubble = Color(0xFFE5E5EA); // Bot message bubble
  static const Color darkBotBubble = Color(0xFF3A3A3C); // Dark bot bubble

  // Utility colors
  static const Color shadow = Color(0x1A000000); // 10% black shadow
  static const Color divider = Color(0xFFE5E5EA);
  static const Color darkDivider = Color(0xFF3A3A3C);
}

class AppTheme {
  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.25,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.25,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: -0.25,
      ),
      titleSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: -0.25,
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: -0.25,
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: -0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: -0.25,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: -0.25,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.shadow,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      actionsIconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.primary.withOpacity(0.5);
            }
            return AppColors.primary;
          },
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        elevation: MaterialStateProperty.all<double>(0),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(AppColors.primary),
        overlayColor: MaterialStateProperty.all<Color>(
          AppColors.primary.withOpacity(0.1),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(AppColors.primary),
        overlayColor: MaterialStateProperty.all<Color>(
          AppColors.primary.withOpacity(0.1),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondarySurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    textTheme: _buildTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black26,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      actionsIconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.primary.withOpacity(0.5);
            }
            return AppColors.primary;
          },
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        elevation: MaterialStateProperty.all<double>(0),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(AppColors.primary),
        overlayColor: MaterialStateProperty.all<Color>(
          AppColors.primary.withOpacity(0.1),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(AppColors.primary),
        overlayColor: MaterialStateProperty.all<Color>(
          AppColors.primary.withOpacity(0.1),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSecondarySurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: AppColors.darkTextSecondary,
      suffixIconColor: AppColors.darkTextSecondary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    textTheme: _buildTextTheme().apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
  );
}