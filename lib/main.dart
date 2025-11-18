import 'package:knotwork/add_node.dart';
import 'package:knotwork/projects/graph/graph_provider.dart';
import 'package:knotwork/home_screen.dart';
import 'package:knotwork/policies_page.dart';
import 'package:knotwork/providers/api_provider.dart';
import 'package:knotwork/providers/theme_provider.dart';
import 'package:knotwork/settings_page.dart';
import 'package:knotwork/actions_timeline.dart';
import 'package:flutter/material.dart';
import 'package:knotwork/auth/auth_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'themes.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // InAppWebViewPlatform.instance = InAppWebViewPlatform();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.transparent, // your theme color here
  //   systemNavigationBarIconBrightness: Brightness.light, // or Brightness.dark
  // ));
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  await dotenv.load(fileName: "assets/.env");
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

  // if (WebView.platform == null) {
  //   WebView.platform = SurfaceAndroidWebView();
  // }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Text(
          'Something went wrong!\n${details.exception}',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  };

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ApiProvider()),
      ChangeNotifierProvider(create: (_) => GraphProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MainApp(isLoggedIn: accessToken != null || refreshToken != null),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GraphProvider>(context, listen: false).fetchActionMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      themeMode: themeProvider.flutterThemeMode,
      // theme: AppTheme.lightTheme.copyWith(
      //   navigationBarTheme: const NavigationBarThemeData(
      //     backgroundColor: Colors.white,
      //     indicatorShape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(10)),
      //     ),
      //     height: kToolbarHeight + 10,
      //     overlayColor: WidgetStatePropertyAll(Colors.white),
      //     surfaceTintColor: Colors.white,
      //   ),
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Colors.white,
      //   ),
      //   menuBarTheme: const MenuBarThemeData(
      //     style: MenuStyle(
      //       elevation: WidgetStatePropertyAll(0),
      //     ),
      //   ),
      //   scaffoldBackgroundColor: Colors.white,
      //   snackBarTheme: const SnackBarThemeData(
      //     backgroundColor: Colors.white,
      //     closeIconColor: Colors.black,
      //     contentTextStyle: TextStyle(color: Colors.black),
      //     actionTextColor: Colors.black,
      //   ),
      // ),
      // darkTheme: AppTheme.darkTheme.copyWith(
      //   navigationBarTheme: const NavigationBarThemeData(
      //     backgroundColor: Color(0xFF1E1E1E),
      //     indicatorShape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(10)),
      //     ),
      //     height: kToolbarHeight + 10,
      //     overlayColor: WidgetStatePropertyAll(Color.fromRGBO(30, 30, 30, 0.5)),
      //     surfaceTintColor: Color.fromRGBO(24, 26, 32, 1),
      //   ),
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Color(0xFF1E1E1E),
      //   ),
      //   menuBarTheme: const MenuBarThemeData(
      //     style: MenuStyle(
      //       elevation: WidgetStatePropertyAll(0),
      //     ),
      //   ),
      //   scaffoldBackgroundColor: const Color(0xFF121212),
      //   snackBarTheme: const SnackBarThemeData(
      //       backgroundColor: Color(0xFF1E1E1E),
      //       closeIconColor: Colors.white,
      //       contentTextStyle: TextStyle(color: Colors.white),
      //       actionTextColor: Colors.white,
      //       shape: RoundedRectangleBorder(
      //         side: BorderSide(
      //           color: theme.colorScheme.primary,
      //           width: 2.0,
      //         ),
      //       )),
      // ),
      initialRoute: widget.isLoggedIn ? "/home" : "/login",
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => HomeScreen(),
        "/policies": (context) => PoliciesPage(),
        "/settings": (context) => SettingsPage(),
        "/timeline": (context) => TimelinesPage(),
        "/addNode": (context) => AddNodePage(),
      },
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
