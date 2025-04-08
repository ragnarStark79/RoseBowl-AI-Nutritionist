import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F8F8), // soft off-white
    primaryColor: Colors.black,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.black,
      secondary: Colors.grey.shade700,
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.all(8),
    ),
    useMaterial3: true,
  );
}
