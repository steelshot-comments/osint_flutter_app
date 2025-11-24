import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
part 'classes.dart';

final PRODUCTION_FASTAPI_URL = dotenv.env['PRODUCTION_FASTAPI_URL'];
final FASTAPI_URL = dotenv.env['FASTAPI_URL'];

enum GraphStatus { idle, loading, loaded, error }

final neo4j_api_url = dotenv.env['NEO4J_API_URL'];
final Dio dio = Dio()
  ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

class GraphProvider extends ChangeNotifier {

  // declaration
  List<Map<String, dynamic>> _nodes = [];
  List<String> _nodeLabels = [];
  List<Map<String, dynamic>> _edges = [];
  List<String> _edgeLabels = [];
  final Map<String, Color> _labelColors = {
    "Person": Colors.blue,
    "Trafficker": Colors.red,
    "Victim": Colors.yellow,
    "Client": Colors.teal,
    "Phone number": Colors.pink,
    "Transcation": Colors.brown,
  };
  final Map<String, List<Map<String, String>>> _actionMap = {};
  bool _hasFetchedOnce = false;
  int _tab_id = 1;

  // states
  bool _isMapMode = false;
  bool _isTableView = false;
  bool _isModeSelection = false;
  bool _filterPanelVisible = false;
  bool _isLoading = false;
  bool _hasData = false;

  // getters

  bool get hasFetchedOnce => _hasFetchedOnce;
  List<Map<String, dynamic>> get nodes => _nodes;
  List<String> get nodeLabels => _nodeLabels;
  List<Map<String, dynamic>> get edges => _edges;
  List<String> get edgeLabels => _edgeLabels;
  Map<String, Color> get labelColors => _labelColors;
  int get getTabId => _tab_id;
  bool get isMapMode => _isMapMode;
  bool get isTableView => _isTableView;
  bool get isModeSelection => _isModeSelection;
  bool get isFilterPanelVisible => _filterPanelVisible;
  bool get isLoading => _isLoading;
  bool get hasData => _hasData;

  // setters

  void toggleMapMode() {
    _isMapMode = !isMapMode;
  }

  void toggleTableView() {
    _isTableView = !isTableView;
  }

  void toggleModeSelection() {
    _isModeSelection = !isModeSelection;
  }

  void toggleFilterPanelVisible() {
    _filterPanelVisible = !isFilterPanelVisible;
  }

  void setLoading(bool value) {
    _isLoading = !isLoading;
  }

  void setData(bool value) {
    _hasData = !hasData;
  }

  void setTabId(int id) {
    _tab_id = id;
  }

  void setGraphData(
      List<Map<String, dynamic>> nodes, List<Map<String, dynamic>> edges) {
    _nodes = nodes;
    _edges = edges;
    setLabels(nodes, edges);
    _assignColorsToLabels();
    notifyListeners();
  }

  void addNodes(List<Map<String, dynamic>> nodes) {
    _nodes.addAll(nodes);
  }

  // remove nodes from graph
  void removeNodes(List<String> ids) {
    for (var id in ids) {
      _nodes.removeWhere((node) => node['id'] == id);
      _edges
          .removeWhere((edge) => edge['source'] == id || edge['target'] == id);
    }

    notifyListeners();
  }

  void setLabels(
      List<Map<String, dynamic>> nodes, List<Map<String, dynamic>> edges) {
    for (var node in nodes) {
      // print(node);
      for (var label in node['labels'] ?? []) {
        if (!_nodeLabels.contains(label)) {
          _nodeLabels.add(label);
        }
      }
    }
    notifyListeners();
  }

  void _assignColorsToLabels() {
    final availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.lime,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.blueGrey,
      Colors.grey,
      Colors.yellow,
    ];

    int colorIndex = 0;
    for (var node in _nodes) {
      for (var label in node['labels'] ?? []) {
        if (!_labelColors.containsKey(label)) {
          _labelColors[label] =
              availableColors[colorIndex % availableColors.length];
          colorIndex++;
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "nodes": nodes,
      "edges": edges,
    };
  }

  Map<String, List<Map<String, dynamic>>> getNodesGroupedByLabel() {
    Map<String, List<Map<String, dynamic>>> groupedNodes = {};

    for (var node in _nodes) {
      List<String> labels = node['labels'] is List<dynamic>
          ? List<String>.from(node['labels'])
          : [];

      if (labels.isEmpty) {
        labels = ['Uncategorized'];
      }

      for (var label in labels) {
        groupedNodes.putIfAbsent(label, () => []).add(node);
      }
    }

    return groupedNodes;
  }

  List<Map<String, String>>? getActionsForLabel(String label) {
    return _actionMap[label];
  }

  Future<void> fetchActionMap() async {
    final response = await dio.get("$FASTAPI_URL/action-map");
    final data = Map<String, dynamic>.from(response.data);
    // print("----------------- $data -----------------------");
    _actionMap.clear();
    data.forEach((key, value) {
      _actionMap[key] = List<Map<String, String>>.from(
        (value as List).map((e) => Map<String, String>.from(e)),
      );
    });
    notifyListeners();
  }

  void fetchAndSetProvider() async {
    final response = await _fetchGraphData();
    _setGraphProvider(response);
  }

  Future<Response> _fetchGraphData() async {
    try {
      final response = await dio.post('$neo4j_api_url/graph',
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
          data: {
            "user_id": "550e8400-e29b-41d4-a716-446655440000",
            "project_id": "550e8400-e29b-41d4-a716-446655440000",
            "graph_id": "550e8400-e29b-41d4-a716-446655440000",
          });
      return response;
    } catch (e) {
      setLoading(false);
      throw Error();
    }
  }

  void _setGraphProvider(Response response) async {
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
        setGraphData(nodes, edges);
        setLabels(nodes, edges);

        setData(true);
        setLoading(false);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content:
        //         Text("Invalid response structure: Missing 'nodes' or 'edges'"),
        //   ),
        // );
      }
    } else {
      debugPrint("Failed to fetch graph data: ${response.statusCode}");
    }
  }

  Future<String> deleteAllNodes() async {
    try {
      final response = await dio.delete("$neo4j_api_url/delete-all-nodes",
          data: {"user_id": 1, "project_id": "1", "graph_id": ""});
      return "success";
    } catch (e) {
      return "$e";
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error: $e")),
      // );
    }
  }
}
