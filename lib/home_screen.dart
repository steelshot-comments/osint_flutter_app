import 'package:final_project/graph/graph_view.dart';
import 'package:final_project/map/map.dart';
import 'package:final_project/settings_page.dart';
import 'package:final_project/view_data.dart';
import 'package:flutter/material.dart';
import 'add_record.dart';
// import 'package:map_test/components/dropdown.dart';

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
      // appBar: AppBar(
      //     title: Text("Welcome ${displayName.toString()}!"),
      //     actions: [
      //       IconButton(
      //           onPressed: () {
      //             Navigator.of(context).push(MaterialPageRoute(
      //                 builder: (context) => const ProfileCopy()));
      //           },
      //           icon: const Icon(Icons.person))
      //     ]),
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
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: <Widget>[
        GraphView(),
        SettingsPage()
      ][currentPageIndex],
    );
  }
}
