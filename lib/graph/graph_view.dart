import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:final_project/components/button.dart';
import 'package:final_project/components/transform_button.dart';
import 'package:final_project/custom_webview.dart';
import 'package:final_project/graph/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

final dio = Dio();

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late final WebViewController _controller = WebViewController();
  Map<String, dynamic>? selectedNode; // Holds the currently selected node
  bool isMapMode = false;
  bool isTableView = false;
  bool isModeSelection = false;
  bool filterPanelVisible = false;
  bool isLoading = false;
  bool hasData = false;
  bool _isControllerReady = false;

  Future<Response> _fetchGraphData() async {
    try {
      final response = await dio.post('http://192.168.0.114:5500/graph',
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
          data: {
            "user_id": "1",
            "tab_id": "1",
          });
      return response;
    } catch (e) {
      print("Error fetching graph data: $e");
      throw Error();
    }
  }

  void _displayGraphData(BuildContext context, Response response) async {
    final graphProvider = Provider.of<GraphProvider>(context, listen: false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;

      if (data['nodes'] is List && data['edges'] is List) {
        // Safely cast the lists
        List<Map<String, dynamic>> nodes = (data['nodes'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        List<Map<String, dynamic>> edges = (data['edges'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        // print(edges);
        graphProvider.setGraphData(nodes, edges);
        graphProvider.setLabels(nodes, edges);
        await graphProvider.fetchActionMap();

        // Convert JSON to a string, escaping special characters
        final jsonData = jsonEncode(graphProvider.toJson());
        final escapedJson = jsonEncode(jsonData);

        _controller.runJavaScript("window.updateGraphData($escapedJson)");
        setState(() {
          isLoading = false;
        });
        setState(() {
          hasData = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Invalid response structure: Missing 'nodes' or 'edges'")));
      }
    } else {
      debugPrint("Failed to fetch graph data: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _initializeWebViewAndGraph();
  }

  Future<void> _initializeWebViewAndGraph() async {
    try {
      final response = await _fetchGraphData();

      if (response.statusCode == 200) {
        _controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..clearCache()
          ..setBackgroundColor(Colors.transparent)
          ..addJavaScriptChannel(
            "FlutterGraphChannel",
            onMessageReceived: (JavaScriptMessage message) {
              Map<String, dynamic> nodeData =
                  Map<String, dynamic>.from(jsonDecode(message.message));

              setState(() {
                selectedNode = nodeData;
              });
            },
          );
        _controller.setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              _displayGraphData(context, response);
            },
          ),
        );
        _controller.loadFlutterAsset('assets/web/graph.html');

        setState(() {
          _isControllerReady = true;
        });
      } else {
        debugPrint("Failed to fetch graph data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error initializing web view: $e");
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

  void searchGraph(query, filter) {
    final finalQuery = jsonEncode(query);
    final finalFilter = jsonEncode(filter);
    _controller.runJavaScript("window.searchGraph($finalQuery, $finalFilter)");
  }

  void _deleteAllNodes() async {
    try {
      final response = await Dio().delete(
          "http://192.168.0.114:5500/delete-all-nodes",
          data: {"user_id": 1, "tab_id": 1});
      _controller.reload();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
                Positioned.fill(child: Text("")
                // Builder(builder: (context) {
                //   if (isLoading || !_isControllerReady) {
                //     return Center(child: CircularProgressIndicator());
                //   } else if (hasData) {
                //     return isTableView
                //         ? TableView()
                //         : CustomWebView(
                //             assetUrl: 'assetUrl',
                //             onMessage: () {},
                //             onControllerReady:
                //                 () {}); //WebViewWidget(controller: _controller);
                //   } else {
                //     return Center(child: Text("No data found!"));
                //   }
                // })
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
                if (filterPanelVisible)
                  FilterPanel(
                    searchGraph: searchGraph,
                  ),
              ],
            ),
          ),
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
                onPressed: () async {
                  final response = await _fetchGraphData();
                  if (response.statusCode == 200) {
                    _displayGraphData(context, response);
                  }
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
              ToolItem(
                icon: Icons.clear,
                onPressed: _deleteAllNodes,
                tooltip: "Delete all nodes",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
