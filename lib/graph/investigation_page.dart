import 'dart:convert';

import 'package:Knotwork/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:Knotwork/components/button.dart';
import 'package:Knotwork/components/transform_button.dart';
import 'package:Knotwork/custom_webview.dart';
import 'package:Knotwork/graph/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import './filters.dart';
import 'package:flutter/services.dart';
import './graph_provider.dart';
part 'node_details_panel.dart';
part 'tabs.dart';
part 'menubar.dart';
part 'tableView.dart';

final NEO4J_API_URL = dotenv.env['NEO4J_API_URL'];

class InvestigationPage extends StatefulWidget {
  const InvestigationPage({super.key});

  @override
  _InvestigationPageState createState() => _InvestigationPageState();
}

class _InvestigationPageState extends State<InvestigationPage> {
  late final WebViewController _controller = WebViewController();
  Map<String, dynamic>? selectedNode; // Holds the currently selected node
  bool isMapMode = false;
  bool isTableView = false;
  bool isModeSelection = false;
  bool filterPanelVisible = false;
  bool isLoading = false;
  bool hasData = false;

  Future<Response> _fetchGraphData() async {
    print(
        "tab_id: ${Provider.of<GraphProvider>(context, listen: false).getTabId}");
    try {
      final response = await Dio().post('$NEO4J_API_URL/graph',
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
          data: {
            "user_id": 1,
            "tab_id":
                Provider.of<GraphProvider>(context, listen: false).getTabId,
          });
      return response;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Error();
    }
  }

  void _setGraphProvider(BuildContext context, Response response) async {
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

        setState(() {
          hasData = true;
        });
        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Invalid response structure: Missing 'nodes' or 'edges'"),
          ),
        );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndSetProvider();
    });
  }

  void _fetchAndSetProvider() async {
    Response response;
    // if (!Provider.of<GraphProvider>(context, listen: false).hasFetchedOnce) {
    response = await _fetchGraphData();
    _setGraphProvider(context, response);
    // }
  }

  void onMessage(JavaScriptMessage message) {
    Map<String, dynamic> nodeData =
        Map<String, dynamic>.from(jsonDecode(message.message));
    setState(() {
      selectedNode = nodeData;
    });
  }

  void showNodeDetails(Map<String, dynamic> node) {
    setState(() {
      selectedNode = node;
    });
  }

  void closeNodeDetails() {
    setState(() {
      selectedNode = null;
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
      final response = await Dio().delete("$NEO4J_API_URL/delete-all-nodes",
          data: {"user_id": 1, "tab_id": 1});
      // if (response.statusCode == 200) {
      //   _controller.reload();
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!isMapMode && !isLoading && hasData)
          ? AppBar(
              automaticallyImplyLeading: false,
              title: MyMenuBar(),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Tabs(),
              ),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: Builder(builder: (context) {
                  if (isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (hasData) {
                    return isTableView
                        ? TableView()
                        : CustomWebView(
                            assetUrl: 'assets/web/graph.html',
                            onMessage: onMessage,
                            controller: _controller,
                          );
                  } else {
                    return Padding(
                      padding: EdgeInsetsGeometry.only(left: 16, right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Error fetching graph data: Cannot connect to the server",
                            style: TextStyle(fontSize: 18),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => {Navigator.of(context).pop()},
                                child: Text("Try again"),
                              ),
                              TextButton(
                                onPressed: () => {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  )
                                },
                                child: Text("Go back"),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }
                })),
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
          if (!isLoading && hasData)
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
                    // final response = await _fetchGraphData();
                    // _setGraphProvider(context, response);
                    _controller.reload();
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
                    throw new Exception();
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
