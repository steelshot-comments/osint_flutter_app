// import 'package:final_project/entity_manager.dart';
import 'package:final_project/graph/graph_provider.dart';
import 'package:final_project/home_screen.dart';
import 'package:final_project/policies_page.dart';
import 'package:final_project/providers/api_provider.dart';
import 'package:final_project/providers/theme_provider.dart';
import 'package:final_project/settings_page.dart';
import 'package:flutter/material.dart';
// import 'package:final_project/home_screen.dart';
import 'package:final_project/auth/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is ready
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? accessToken = await secureStorage.read(key: "access_token");
  String? refreshToken = await secureStorage.read(key: "refresh_token");

  if (accessToken != null) {
    debugPrint("Access token found!");
  } else {
    // Refresh token if needed
    final newToken = await refreshAccessToken();
    accessToken =
        newToken ?? accessToken; // Use the refreshed token if available
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ApiProvider()),
      ChangeNotifierProvider(create: (_) => GraphProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MainApp(isLoggedIn: accessToken != null || refreshToken != null),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      themeMode: themeProvider.flutterThemeMode,
      theme: ThemeData(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            height: kToolbarHeight + 10,
            overlayColor: const WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: Colors.white,
          ),
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(121, 191, 172, 1)),
          textTheme: TextTheme(),
          appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          menuBarTheme: MenuBarThemeData(
            style: MenuStyle(
              elevation: WidgetStatePropertyAll(0),
            ),
          ),
          scaffoldBackgroundColor: Colors.white),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(
              80, 130, 120, 1), // Darker shade of light mode color
          brightness: Brightness.dark, // Ensures dark mode appearance
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color.fromRGBO(18, 18, 18, 1), // Dark background
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          height: kToolbarHeight + 10,
          overlayColor: const WidgetStatePropertyAll(
              Color.fromRGBO(30, 30, 30, 0.5)), // Slightly lighter overlay
          surfaceTintColor:
              Color.fromRGBO(24, 26, 32, 1), // Subtle tint for depth
        ),

        textTheme: TextTheme(), // Can be customized later
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
        ), // Dark gray/black for contrast
        menuBarTheme: MenuBarThemeData(
          style: MenuStyle(
            elevation: WidgetStatePropertyAll(0),
          ),
        ),
        scaffoldBackgroundColor:
            Color(0xFF121212), // Standard dark mode background
      ),
      initialRoute: isLoggedIn ? "/home" : "/login",
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => HomeScreen(),
        "/policies": (context) => PoliciesPage(),
        "/settings": (context) => SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
