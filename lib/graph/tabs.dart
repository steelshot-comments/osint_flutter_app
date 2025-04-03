part of 'graph_view.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  List<String> _tabs = ["Tab 1"];
  late TabController _tabController;
  int _tabCount = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addNewTab() {
    setState(() {
      _tabCount++;
      _tabs.add("Tab $_tabCount");

      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: _tabs.length - 1,
      );
    });

    _loadDataForTab(_tabs.length - 1);
  }

  void _loadDataForTab(int index) {
    String dataUrl = "/assets/web/graph.html"; // Replace with real URLs
    // _controller.loadRequest(Uri.parse(dataUrl));
  }

  void _renameTab(int index) {
    TextEditingController textController =
        TextEditingController(text: _tabs[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename Tab"),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter tab name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tabs[index] = textController.text.isNotEmpty
                      ? textController.text
                      : _tabs[index]; // Keep old name if empty
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTab(int index) {
    if (_tabs.length == 1) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot delete the last tab!")),
      );
      return;
    }

    setState(() {
      _tabCount--;
      _tabs.removeAt(index);

      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: (_tabs.length - 1).clamp(0, _tabs.length - 1),
      );
    });
  }

  void _showTabOptions(int index) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text("Rename"),
            onTap: () {
              Navigator.pop(context);
              _renameTab(index);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              _deleteTab(index);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              
              // indicatorSize: TabBarIndicatorSize.tab,
              tabs: _tabs.map((name) {
                int index = _tabs.indexOf(name);
                return GestureDetector(
                  onLongPress: () => _showTabOptions(index),
                  child: Tab(text: name),
                );
              }).toList(),
              onTap: (index) => _loadDataForTab(index),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _addNewTab,
          tooltip: "New Tab",
        ),
      ],
    );
  }
}
