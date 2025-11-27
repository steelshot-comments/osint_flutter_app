import 'package:flutter/material.dart';

/// Centralized Material 3 color and theme configuration.
class AppTheme {
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
    navigationBarTheme: const NavigationBarThemeData(
      // indicatorShape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.all(Radius.circular(10)),
      // ),
      height: kToolbarHeight + 10,
      // overlayColor: WidgetStatePropertyAll(Colors.white),
      surfaceTintColor: Colors.white,
    ),
    menuBarTheme: const MenuBarThemeData(
      style: MenuStyle(
        elevation: WidgetStatePropertyAll(0),
      ),
    ),
    // snackBarTheme: const SnackBarThemeData(
    //   backgroundColor: Colors.white,
    //   closeIconColor: Colors.black,
    //   contentTextStyle: TextStyle(color: Colors.black),
    //   actionTextColor: Colors.black,
    // ),
  );

  /// ThemeData for dark mode
  static final ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
    navigationBarTheme: const NavigationBarThemeData(
      // backgroundColor: Color(0xFF1E1E1E),
      // indicatorShape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.all(Radius.circular(10)),
      // ),
      height: kToolbarHeight + 10,
      overlayColor: WidgetStatePropertyAll(Color.fromRGBO(30, 30, 30, 0.5)),
      surfaceTintColor: Color.fromRGBO(24, 26, 32, 1),
    ),
    menuBarTheme: const MenuBarThemeData(
      style: MenuStyle(
        elevation: WidgetStatePropertyAll(0),
      ),
    ),
    // snackBarTheme: const SnackBarThemeData(
    //   backgroundColor: Color(0xFF1E1E1E),
    //   closeIconColor: Colors.white,
    //   contentTextStyle: TextStyle(color: Colors.white),
    //   actionTextColor: Colors.white,
    // ),
  );

  /// Helper getters for convenience
  static Color get primary => lightColorScheme.primary;
  static Color get surfaceTint => lightColorScheme.surfaceTint;
  static Color get onPrimary => lightColorScheme.onPrimary;
  static Color get secondary => lightColorScheme.secondary;
}
