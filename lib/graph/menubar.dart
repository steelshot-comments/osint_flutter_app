part of 'graph_view.dart';

class MyMenuBar extends StatefulWidget {
  const MyMenuBar({super.key});

  @override
  State<MyMenuBar> createState() => _MyMenuBarState();
}

class _MyMenuBarState extends State<MyMenuBar> {
  Widget _buildMenu(String title, List<String> options) {
    return SubmenuButton(
      menuChildren: options.map((option) {
        return MenuItemButton(
          child: Text(option,),
          onPressed: () {
            debugPrint("$title - $option selected");
          },
        );
      }).toList(),
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        _buildMenu("File", ["New", "Open", "Save"]),
        _buildMenu("Graph", ["View 1", "View 2", "View 3"]),
        _buildMenu("Entity", ["Add Person", "Add Company", "Add Location"]),
        _buildMenu("Transforms", ["Run All", "Custom Query", "Export Data"]),
      ],
    );
  }
}
