import 'package:flutter/material.dart';

class Tools extends StatefulWidget {
  const Tools({super.key, required this.tools});

  final List<ToolItem> tools;

  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GridView.count(
        crossAxisCount: 8,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Prevents internal scrolling
        children: List.generate(widget.tools.length, (index) {
          return IconButton(
            icon: Icon(widget.tools[index].icon),
            onPressed: widget.tools[index].onPressed,
            tooltip: widget.tools[index].tooltip,
          );
        }),
      ),
    );
  }
}

class ToolItem {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  ToolItem(
      {required this.icon, required this.onPressed, required this.tooltip});
}
