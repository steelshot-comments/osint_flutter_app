part of 'investigation_page.dart';

class MyMenuBar extends StatefulWidget {
  const MyMenuBar({super.key});

  @override
  State<MyMenuBar> createState() => _MyMenuBarState();
}

class _MyMenuBarState extends State<MyMenuBar> {
  /// Builds a submenu entry like "File", "Edit", etc.
  Widget _buildMenu(String title, List<Map<String, VoidCallback>> options) {
    return SubmenuButton(
      menuChildren: options.map((option) {
        final String label = option.keys.first;
        final VoidCallback action = option.values.first;

        return MenuItemButton(
          child: Text(label),
          onPressed: action,     // FIXED: Actually calls the callback
        );
      }).toList(),
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        _buildMenu("File", [
          {"New": () {}},
          {"Open": () {}},
        ]),
        _buildMenu("Graph", [
          {"View 1": () {}},
        ]),
        _buildMenu("Entity", [
          {"Add Person": () {}},
        ]),
        _buildMenu("Transforms", [
          {"Run All": () {}},
        ]),
        _buildMenu("Window", [
          {"Go back": () => Navigator.of(context).pop()},
          {"Go Forward": () {}},
          {"Go to settings": () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsPage()));
          }},
        ]),
      ],
    );
  }
}
