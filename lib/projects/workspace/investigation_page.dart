import 'dart:convert';

import 'package:knotwork/edit_node.dart';
import 'package:dio/dio.dart';
import 'package:knotwork/components/button.dart';
import 'package:knotwork/components/transform_button.dart';
import 'package:knotwork/projects/workspace/webview/custom_webview.dart';
import 'package:knotwork/projects/workspace/map/map.dart';
import 'package:knotwork/projects/workspace/tools.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:knotwork/providers/webview_provider.dart';
// import 'package:webview_all/webview_all.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';
part 'webview/node_details_panel.dart';
part 'tabs.dart';
part 'menubar.dart';
part 'table/tableView.dart';
part 'webview/webview.dart';
part 'content_view.dart';

class InvestigationPage extends StatefulWidget {
  const InvestigationPage({super.key});

  @override
  _InvestigationPageState createState() => _InvestigationPageState();
}

class _InvestigationPageState extends State<InvestigationPage> {
  // InAppWebViewController? _controller;
  late GraphProvider graphProvider;
  late WebViewProvider webViewProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      graphProvider.loadGraph();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    graphProvider = Provider.of<GraphProvider>(context, listen: false);
    webViewProvider = Provider.of<WebViewProvider>(context, listen: false);
  }

  Widget _buildTools() {
    return Tools(
      tools: [
        ToolItem(
            icon: Icons.search,
            onPressed: graphProvider.toggleFilterPanelVisible,
            tooltip: "Search"),
        ToolItem(
            icon: Icons.table_chart,
            onPressed: graphProvider.loadTable,
            tooltip: "Table View"),
        ToolItem(
          icon: Icons.map,
          onPressed: graphProvider.toggleZenMode,
          tooltip: "Zen Mode",
        ),
        ToolItem(
          icon: Icons.select_all,
          onPressed: graphProvider.toggleSelectionMode,
          tooltip:
              graphProvider.isSelectionMode ? "Panning mode" : "Selection mode",
        ),
        ToolItem(
          icon: Icons.refresh,
          onPressed: () async {
            graphProvider.loadGraph();
          },
          tooltip: "Refresh graph",
        ),
        ToolItem(
          icon: Icons.add,
          onPressed: () => Navigator.of(context).pushNamed("/addNode"),
          tooltip: "Add node",
        ),
        ToolItem(
          icon: Icons.arrow_circle_right_outlined,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Create edges not implemented yet")),
            );
          },
          tooltip: "Create edges",
        ),
        ToolItem(
          icon: Icons.undo,
          onPressed: () {},
          tooltip: "Undo",
        ),
        ToolItem(
          icon: Icons.redo,
          onPressed: () {},
          tooltip: "Redo",
        ),
        ToolItem(
          icon: Icons.clear,
          onPressed: graphProvider.deleteAllNodes,
          tooltip: "Delete all nodes",
        ),
      ],
      toolDropdowns: [
        ToolDropdown(name: "Graph layout", dropDownItems: [
          ToolItem(
              icon: Icons.graphic_eq,
              onPressed: () => webViewProvider.changeLayout('cose'),
              tooltip: "Normal Graph View"),
          ToolItem(
              icon: Icons.hub,
              onPressed: () => webViewProvider.changeLayout('breadthfirst'),
              tooltip: "Hierarchical Graph View"),
          ToolItem(
              icon: Icons.shuffle,
              onPressed: () => webViewProvider.changeLayout('random'),
              tooltip: "Random"),
          ToolItem(
              icon: Icons.grid_3x3,
              onPressed: () => webViewProvider.changeLayout('grid'),
              tooltip: "Grid"),
          ToolItem(
              icon: Icons.circle,
              onPressed: () => webViewProvider.changeLayout('circle'),
              tooltip: "Circle"),
          ToolItem(
              icon: Icons.circle,
              onPressed: () => webViewProvider.changeLayout('concentric'),
              tooltip: "Concentric"),
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const MyMenuBar(),
      ),
      body: Column(
        children: [const ContentView(selectedIndex: 0), _buildTools()],
      ),
    );
  }
}
