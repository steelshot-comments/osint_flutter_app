import 'dart:convert';

import 'package:final_project/components/transform_button.dart';
import 'package:final_project/components/transform_status.dart';
import 'package:final_project/graph/tools.dart';
import 'package:final_project/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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
  bool filterPanelVisible = false;

  void _fetchGraphData(BuildContext context) async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.114:5500/graph'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('nodes') && data.containsKey('edges')) {
          final graphProvider =
              Provider.of<GraphProvider>(context, listen: false);

          // ✅ Safely cast the lists
          List<Map<String, dynamic>> nodes = (data['nodes'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          List<Map<String, dynamic>> edges = (data['edges'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          graphProvider.setGraphData(nodes, edges);

          // ✅ Convert JSON to a string, escaping special characters
          final jsonData = jsonEncode(graphProvider.toJson())
              .replaceAll("'", r"\'")
              .replaceAll('"', r'\"');

          // ✅ Ensure the function is called correctly in JavaScript
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

  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search"),
          content: TextField(
            decoration: InputDecoration(hintText: "Enter search query"),
            onSubmitted: (query) {
              Navigator.pop(context);
              _controller.runJavaScript("window.searchGraph('$query')");
            },
          ),
        );
      },
    );
  }

  void changeLayout(String layoutName) {
    _controller.runJavaScript("window.switchToLayout('$layoutName')");
  }

  void toggleFilterPanel(BuildContext context) {
    setState(() {
      filterPanelVisible = !filterPanelVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ApiProvider>().loadEntities());

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

  void _addNode() {
    // create json object
    // JSON
    var newNode = {
      "id": "13",
      "label": "Wow",
    };
    _controller.runJavaScript("window.receiveData($newNode)");
  }

  @override
  Widget build(BuildContext context) {
    var apiProvider = context.watch<ApiProvider>();
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
      body: Stack(
        children: [
          Positioned.fill(
            child: isTableView
                ? TableView()
                : WebViewWidget(controller: _controller),
          ),
          // Show NodeDetailsPanel only when a node is selected
          if (selectedNode != null)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: NodeDetailsPanel(
                node: selectedNode!,
                onClose: closeNodeDetails, // Pass the close function
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Tools(
              functions: [
                _openSearchDialog,
                () => toggleFilterPanel(context),
                () => isTableViewMode(),
                () => changeLayout('cose'),
                () => changeLayout('breadthfirst'),
                () => changeLayout('random'),
                () => changeLayout('grid'),
                () => changeLayout('circle'),
                () => changeLayout('concentric'),
                _toggleMapMode
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _addNode,
            // _controller.reload,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
