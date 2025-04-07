import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:final_project/components/button.dart';
import 'package:final_project/components/transform_button.dart';
import 'package:final_project/graph/tools.dart';
import 'package:final_project/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import './filters.dart';
import 'package:flutter/services.dart';
import './graph_provider.dart';
part 'node_details_panel.dart';
part 'tabs.dart';
part 'menubar.dart';
part 'tableView.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late final WebViewController _controller;
  Map<String, dynamic>? selectedNode; // Holds the currently selected node
  bool isMapMode = false;
  bool isTableView = false;
  bool isModeSelection = false;
  bool filterPanelVisible = false;

  void _fetchGraphData(BuildContext context) async {
    try {
      final response =
          await http.post(Uri.parse('http://192.168.0.114:5500/graph'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "user_id": "1",
                "tab_id": "1",
              }));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['nodes'] is List && data['edges'] is List) {
          final graphProvider =
              Provider.of<GraphProvider>(context, listen: false);

          // Safely cast the lists
          List<Map<String, dynamic>> nodes = (data['nodes'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          List<Map<String, dynamic>> edges = (data['edges'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          graphProvider.setGraphData(nodes, edges);
          graphProvider.setLabels(nodes, edges);

          // Convert JSON to a string, escaping special characters
          final jsonData = jsonEncode(graphProvider.toJson())
              .replaceAll("'", r"\'")
              .replaceAll('"', r'\"');
              
          _controller.runJavaScript("window.updateGraphData(\"$jsonData\")");
        } else {
          print("Invalid response structure: Missing 'nodes' or 'edges'");
        }
      } else {
        print("Failed to fetch graph data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching graph data: $e");
    }
  }

  void showNodeDetails(Map<String, dynamic> node) {
    setState(() {
      selectedNode = node;
    });
  }

  void closeNodeDetails() {
    setState(() {
      selectedNode = null; // Hides the panel
    });
  }

  void _toggleMapMode() {
    setState(() {
      isMapMode = !isMapMode;
    });
  }

  void isTableViewMode() {
    setState(() {
      isTableView = !isTableView;
    });
  }

  void changeLayout(String layoutName) {
    _controller.runJavaScript("window.switchToLayout('$layoutName')");
  }

  void toggleFilterPanel(BuildContext context) {
    setState(() {
      filterPanelVisible = !filterPanelVisible;
    });
  }

  void _toggleSelectMode() {
    setState(() {
      isModeSelection = !isModeSelection;
    });
    _controller.runJavaScript(isModeSelection
        ? "window.cy.boxSelectionEnabled(true)"
        : "window.cy.boxSelectionEnabled(false)");
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        "FlutterGraphChannel",
        onMessageReceived: (JavaScriptMessage message) {
          Map<String, dynamic> nodeData =
              Map<String, dynamic>.from(jsonDecode(message.message));

          // Update UI with node details
          setState(() {
            selectedNode = nodeData;
          });
        },
      )
      ..loadFlutterAsset('assets/web/graph.html');

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          _fetchGraphData(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMapMode
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: MyMenuBar(),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Tabs(),
              ),
            ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: isTableView
                      ? TableView()
                      : WebViewWidget(controller: _controller),
                ),
                if (selectedNode != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: NodeDetailsPanel(
                      nodeDetails: selectedNode!,
                      onClose: closeNodeDetails,
                    ),
                  ),
              ],
            ),
          ),
          Visibility(
            visible: filterPanelVisible,
            child: FilterPanel(),
          ),
          Column(children: [
            Tools(
              tools: [
                ToolItem(
                    icon: Icons.search,
                    onPressed: () => toggleFilterPanel(context),
                    tooltip: "Search"),
                ToolItem(
                    icon: Icons.table_chart,
                    onPressed: () => isTableViewMode(),
                    tooltip: "Table View"),
                ToolItem(
                    icon: Icons.graphic_eq,
                    onPressed: () => changeLayout('cose'),
                    tooltip: "Normal Graph View"),
                ToolItem(
                    icon: Icons.hub,
                    onPressed: () => changeLayout('breadthfirst'),
                    tooltip: "Hierarchical Graph View"),
                ToolItem(
                    icon: Icons.shuffle,
                    onPressed: () => changeLayout('random'),
                    tooltip: "Random"),
                ToolItem(
                    icon: Icons.grid_3x3,
                    onPressed: () => changeLayout('grid'),
                    tooltip: "Grid"),
                ToolItem(
                    icon: Icons.circle,
                    onPressed: () => changeLayout('circle'),
                    tooltip: "Circle"),
                ToolItem(
                    icon: Icons.circle,
                    onPressed: () => changeLayout('concentric'),
                    tooltip: "Concentric"),
                ToolItem(
                  icon: Icons.map,
                  onPressed: _toggleMapMode,
                  tooltip: "Zen Mode",
                ),
                ToolItem(
                  icon: Icons.select_all,
                  onPressed: _toggleSelectMode,
                  tooltip: isModeSelection ? "Panning mode" : "Selection mode",
                ),
                ToolItem(
                  icon: Icons.refresh,
                  onPressed: _controller.reload,
                  tooltip: "Refresh graph",
                ),
                ToolItem(
                  icon: Icons.add,
                  onPressed: () => Navigator.of(context).pushNamed("/addNode"),
                  tooltip: "Add node",
                ),
                ToolItem(
                  icon: Icons.arrow_circle_right_outlined,
                  onPressed: () {},
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
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
