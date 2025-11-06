import 'package:Knotwork/graph/investigation_page.dart';
import 'package:Knotwork/projects_page.dart';
import 'package:Knotwork/settings_page.dart';
import 'package:Knotwork/actions_timeline.dart';
import 'package:flutter/material.dart';
// import 'package:linux_webview/linux_webview_plugin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // String? displayName = "user";
    // if (user != null) {
    //   displayName = user.displayName;
    // }

    return Scaffold(
      // appBar:
      //     AppBar(title: Text("Welcome ${displayName.toString()}!"), actions: [
      //   IconButton(
      //       onPressed: () {
      //         Navigator.of(context).push(
      //             MaterialPageRoute(builder: (context) => const ProfileCopy()));
      //       },
      //       icon: const Icon(Icons.person))
      // ]),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "Timeline",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: <Widget>[
        ProjectPage(),
        // InvestigationPage(),
        TimelinesPage(),
        SettingsPage(),
      ][currentPageIndex],
    );
  }
}
