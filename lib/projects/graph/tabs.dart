part of 'investigation_page.dart';

class Tabs extends StatefulWidget {
  final Widget Function(int index) tabContentBuilder;

  const Tabs({
    super.key,
    required this.tabContentBuilder,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  List<String> tabs = ["Graph 1"];
  late TabController _controller;
  int _tabCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this);
    _controller.addListener(() {
      Provider.of<GraphProvider>(context, listen: false)
          .setTabId(_controller.index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addNewTab() {
    setState(() {
      _tabCount++;
      tabs.add("Graph $_tabCount");

      _controller.dispose();
      _controller = TabController(
        length: tabs.length,
        vsync: this,
        initialIndex: tabs.length - 1,
      );
    });

    Provider.of<GraphProvider>(context, listen: false)
        .setTabId(tabs.length - 1);
  }

  void _renameTab(int index) {
    final controller = TextEditingController(text: tabs[index]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Graph"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              setState(() {
                tabs[index] = controller.text.trim().isEmpty
                    ? tabs[index]
                    : controller.text.trim();
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _deleteTab(int index) {
    if (tabs.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete the last tab")),
      );
      return;
    }

    setState(() {
      tabs.removeAt(index);

      _controller.dispose();
      _controller = TabController(
        length: tabs.length,
        vsync: this,
        initialIndex: (index - 1).clamp(0, tabs.length - 1),
      );
    });

    Provider.of<GraphProvider>(context, listen: false)
        .setTabId(_controller.index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                controller: _controller,
                isScrollable: true,
                tabs: List.generate(
                  tabs.length,
                  (i) => GestureDetector(
                    onLongPress: () => _showTabOptions(i),
                    child: Tab(text: tabs[i]),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addNewTab,
            )
          ],
        ),

        // TabBarView must be INSIDE the same widget
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: List.generate(
              tabs.length,
              (i) => widget.tabContentBuilder(i),
            ),
          ),
        ),
      ],
    );
  }

  void _showTabOptions(int index) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Rename"),
            onTap: () {
              Navigator.pop(context);
              _renameTab(index);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              _deleteTab(index);
            },
          ),
        ),
      ],
    );
  }
}


// Tools(
//               tools: [
//                 ToolItem(
//                     icon: Icons.search,
//                     onPressed: () => toggleFilterPanel(context),
//                     tooltip: "Search"),
//                 ToolItem(
//                     icon: Icons.table_chart,
//                     onPressed: () => isTableViewMode(),
//                     tooltip: "Table View"),
//                 ToolItem(
//                   icon: Icons.map,
//                   onPressed: _toggleMapMode,
//                   tooltip: "Zen Mode",
//                 ),
//                 ToolItem(
//                   icon: Icons.select_all,
//                   onPressed: _toggleSelectMode,
//                   tooltip: isModeSelection ? "Panning mode" : "Selection mode",
//                 ),
//                 ToolItem(
//                   icon: Icons.refresh,
//                   onPressed: () async {
//                     // final response = await _fetchGraphData();
//                     // _setGraphProvider(context, response);
//                     // _controller.reload();
//                   },
//                   tooltip: "Refresh graph",
//                 ),
//                 ToolItem(
//                   icon: Icons.add,
//                   onPressed: () => Navigator.of(context).pushNamed("/addNode"),
//                   tooltip: "Add node",
//                 ),
//                 ToolItem(
//                   icon: Icons.arrow_circle_right_outlined,
//                   onPressed: () {
//                     throw new Exception();
//                   },
//                   tooltip: "Create edges",
//                 ),
//                 ToolItem(
//                   icon: Icons.undo,
//                   onPressed: () {},
//                   tooltip: "Undo",
//                 ),
//                 ToolItem(
//                   icon: Icons.redo,
//                   onPressed: () {},
//                   tooltip: "Redo",
//                 ),
//                 ToolItem(
//                   icon: Icons.clear,
//                   onPressed: _deleteAllNodes,
//                   tooltip: "Delete all nodes",
//                 ),
//               ],
//               toolDropdowns: [
//                 ToolDropdown(name: "Graph layout", dropDownItems: [
//                   ToolItem(
//                       icon: Icons.graphic_eq,
//                       onPressed: () => changeLayout('cose'),
//                       tooltip: "Normal Graph View"),
//                   ToolItem(
//                       icon: Icons.hub,
//                       onPressed: () => changeLayout('breadthfirst'),
//                       tooltip: "Hierarchical Graph View"),
//                   ToolItem(
//                       icon: Icons.shuffle,
//                       onPressed: () => changeLayout('random'),
//                       tooltip: "Random"),
//                   ToolItem(
//                       icon: Icons.grid_3x3,
//                       onPressed: () => changeLayout('grid'),
//                       tooltip: "Grid"),
//                   ToolItem(
//                       icon: Icons.circle,
//                       onPressed: () => changeLayout('circle'),
//                       tooltip: "Circle"),
//                   ToolItem(
//                       icon: Icons.circle,
//                       onPressed: () => changeLayout('concentric'),
//                       tooltip: "Concentric"),
//                 ])
//               ],
//             ),