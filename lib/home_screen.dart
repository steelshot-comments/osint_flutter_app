import 'package:knotwork/map/map.dart';
import 'package:knotwork/projects/projects_page.dart';
import 'package:knotwork/settings_page.dart';
import 'package:knotwork/actions_timeline.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
        // TimelinesPage(),
        MapScreen(),
        SettingsPage(),
      ][currentPageIndex],
    );
  }
}
