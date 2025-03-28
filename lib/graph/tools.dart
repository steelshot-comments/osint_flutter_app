import 'package:flutter/material.dart';

class Tools extends StatefulWidget {
  const Tools({super.key, required this.functions});

  final List<VoidCallback> functions;

  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: widget.functions[0],
            tooltip: "Search",
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: widget.functions[1],
            tooltip: "Filter",
          ),
          IconButton(
            icon: Icon(Icons.table_chart),
            onPressed: widget.functions[2],
            tooltip: "Table view",
          ),
          IconButton(
            icon: Icon(Icons.graphic_eq),
            onPressed: widget.functions[3],
            tooltip: "Normal graph view",
          ),
          IconButton(
            icon: Icon(Icons.hub),
            onPressed: widget.functions[4],
            tooltip: "Heirarchical graph view",
          ),
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: widget.functions[5],
            tooltip: "Random",
          ),
          IconButton(
            icon: Icon(Icons.grid_3x3),
            onPressed: widget.functions[6],
            tooltip: "Grid",
          ),
          IconButton(
            icon: Icon(Icons.circle),
            onPressed: widget.functions[7],
            tooltip: "Circle",
          ),
          IconButton(
            icon: Icon(Icons.circle),
            onPressed: widget.functions[8],
            tooltip: "Concentric",
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: widget.functions[9],
            tooltip: "Zen mode",
          ),
        ],
      ),
    );
  }
}
