import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", mode.toString().split('.').last);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString("themeMode");
    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
          (e) => e.toString().split('.').last == savedTheme,
          orElse: () => AppThemeMode.system);
      notifyListeners();
    }
  }
}
