part of 'investigation_page.dart';

class Tabs extends StatefulWidget {
  final Widget Function(int index) tabContentBuilder;
  final ValueChanged<int>? onTabChanged;

  const Tabs({
    super.key,
    required this.tabContentBuilder,
    this.onTabChanged,
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
    _initController(0);
  }

  void _initController(int initialIndex) {
    _controller = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _controller.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_controller.indexIsChanging) {
      widget.onTabChanged?.call(_controller.index);
    }
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
      _initController(tabs.length - 1);
    });

    // Provider.of<GraphProvider>(context, listen: false)
    //     .setTabId(tabs.length - 1);
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
      _initController((index - 1).clamp(0, tabs.length - 1));
    });

    // Provider.of<GraphProvider>(context, listen: false)
    //     .setTabId(_controller.index);
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