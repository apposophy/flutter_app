// lib/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Define the base text theme using Cairo
  static final TextTheme _cairoTextTheme = GoogleFonts.cairoTextTheme();

  // Define the base dark text theme using Cairo (optional, for consistency)
  static final TextTheme _cairoDarkTextTheme =
      GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);

  static final ThemeData lightTheme = ThemeData(
    // Use the Cairo text theme
    textTheme: _cairoTextTheme,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightGreenAccent,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    // Use the Cairo text theme
    textTheme: _cairoDarkTextTheme,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightGreenAccent,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
