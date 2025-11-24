import 'package:flutter/material.dart';

class Tools extends StatefulWidget {
  const Tools({
    super.key,
    required this.tools,
    required this.toolDropdowns,
  });

  final List<ToolItem> tools;
  final List<ToolDropdown> toolDropdowns;

  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  late final List<dynamic> _allTools;

  static const double iconSize = 26; // fixed icon size
  static const double itemWidth = 26; // icon + padding target width

  @override
  void initState() {
    super.initState();
    _allTools = [...widget.tools, ...widget.toolDropdowns];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // dynamic cross-axis count depending on width
    final crossAxisCount =
        (width / itemWidth).floor().clamp(1, _allTools.length);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 8, // horizontal gap between tools
        runSpacing: 4, // vertical gap if it wraps
        alignment: WrapAlignment.start,
        children: _allTools.map((item) {
          if (item is ToolItem) {
            return IconButton(
              iconSize: 30,
              icon: Icon(item.icon),
              tooltip: item.tooltip,
              onPressed: item.onPressed,
            );
          } else if (item is ToolDropdown) {
            return _buildDropdown(item);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown(ToolDropdown dropdown) {
    return PopupMenuButton<ToolItem>(
      tooltip: dropdown.name,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      itemBuilder: (context) {
        return dropdown.dropDownItems.map((tool) {
          return PopupMenuItem<ToolItem>(
            value: tool,
            child: Row(
              children: [
                Icon(tool.icon, size: 10),
                const SizedBox(width: 8),
                Text(tool.tooltip),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (tool) => tool.onPressed(),
    );
  }
}

class ToolItem {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  ToolItem({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });
}

class ToolDropdown {
  final List<ToolItem> dropDownItems;
  final String name;

  ToolDropdown({
    required this.name,
    required this.dropDownItems,
  });
}
