import 'package:knotwork/account_page.dart';
import 'package:knotwork/add_node.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';
import 'package:knotwork/home_screen.dart';
import 'package:knotwork/policies_page.dart';
import 'package:knotwork/projects/workspace/investigation_page.dart';
// import 'package:knotwork/providers/api_provider.dart';
import 'package:knotwork/providers/theme_provider.dart';
import 'package:knotwork/settings_page.dart';
import 'package:knotwork/actions_timeline.dart';
import 'package:flutter/material.dart';
import 'package:knotwork/auth/auth_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'themes.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:knotwork/providers/webview_provider.dart';

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
  final String mapbox_access_token =
      dotenv.env['ACCESS_TOKEN']!;
  MapboxOptions.setAccessToken(mapbox_access_token);

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
      // ChangeNotifierProvider(create: (_) => ApiProvider()),
      ChangeNotifierProvider(create: (_) => GraphProvider()),
      ChangeNotifierProvider(create: (_) => WebViewProvider()),
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
    // Future.microtask(() {
    //   Provider.of<GraphProvider>(context, listen: false).fetchActionMap();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      themeMode: themeProvider.flutterThemeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: widget.isLoggedIn ? "/home" : "/login",
      routes: {
        "/login": (context) => LoginPage(),
        "/home": (context) => HomeScreen(),
        "/investigation": (context) => InvestigationPage(),
        "/policies": (context) => PoliciesPage(),
        "/settings": (context) => SettingsPage(),
        "/timeline": (context) => TimelinesPage(),
        "/addNode": (context) => AddNodePage(),
        "/account": (context) => AccountPage(),
      },
      debugShowCheckedModeBanner: false,
      // home: LoginPage(),
    );
  }
}
