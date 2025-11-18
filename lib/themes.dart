import 'package:flutter/material.dart';

/// Centralized Material 3 color and theme configuration.
class AppTheme {
  // The base color for generating the Material 3 tonal palette
  static const Color seedColor = Color(0xFF6750A4);

  /// Light color scheme (Material 3 tonal palette)
  static final ColorScheme lightColorScheme =
      ColorScheme.fromSeed(seedColor: Color.fromRGBO(121, 191, 172, 1));

  /// Dark color scheme (Material 3 tonal palette)
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor:
        Color.fromRGBO(80, 130, 120, 1), // Darker shade of light mode color
    brightness: Brightness.dark,
  );

  /// ThemeData for light mode
  static final ThemeData lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
  );

  /// ThemeData for dark mode
  static final ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
  );

  /// Helper getters for convenience
  static Color get primary => lightColorScheme.primary;
  static Color get surfaceTint => lightColorScheme.surfaceTint;
  static Color get onPrimary => lightColorScheme.onPrimary;
  static Color get secondary => lightColorScheme.secondary;
}
