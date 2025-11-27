import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knotwork/auth/auth_screen.dart';

part 'classes.dart';

final PRODUCTION_FASTAPI_URL = dotenv.env['PRODUCTION_FASTAPI_URL'];
final FASTAPI_URL = dotenv.env['FASTAPI_URL'];
final NEO4J_API_URL = dotenv.env['NEO4J_API_URL'];

enum ViewStatus { idle, loading, loaded, error }

class GraphProvider with ChangeNotifier {
  /// ----- VIEW STATES -----
  ViewStatus tableStatus = ViewStatus.idle;
  ViewStatus graphStatus = ViewStatus.idle;
  ViewStatus hierarchyStatus = ViewStatus.idle;

  /// Current UI layout/view type (Table / Graph / Hierarchy)
  String currentView = "table";

  /// ----- DATA -----
  List<Node> nodes = [];
  List<Edge> edges = [];

  List<String> get nodeLabels {
    final set = <String>{};
    for (final n in nodes) {
      set.addAll(n.labels);
    }
    return set.toList();
  }

  /// Unique edge labels (relationship types)
  List<String> get edgeLabels {
    final set = <String>{};
    for (final e in edges) {
      if (e.label != null) {
        set.add(e.label!);
      }
    }
    return set.toList();
  }

  /// Selection
  bool _selectionMode = false;
  Set<String> selectedNodeIds = {}; // store by node id

  bool get isSelectionMode => _selectionMode;
  List<Node> get selectedNodes =>
      nodes.where((n) => selectedNodeIds.contains(n.id)).toList();

  /// Toggle selection mode
  void toggleSelectionMode() {
    _selectionMode = !_selectionMode;

    if (!_selectionMode) {
      selectedNodeIds.clear();
    }

    notifyListeners();
  }

  // toggle filter panel
  bool _isFilterPanelVisible = false;
  bool get isFilterPanelVisible => _isFilterPanelVisible;
  void toggleFilterPanelVisible() {
    _isFilterPanelVisible = !_isFilterPanelVisible;
    notifyListeners();
  }

  // toggle zen mode
  bool _isZenMode = false;
  bool get isZenMode => _isZenMode;
  void toggleZenMode() {
    _isZenMode = !_isZenMode;
    notifyListeners();
  }

  /// Mapping labels → color
  Map<String, Color> labelColors = {};

  /// Filters
  String searchQuery = "";
  Map<String, dynamic> propertyFilters = {};

  /// Http client
  final dio = Dio();

  /// ----- SWITCH VIEW -----
  void switchTo(String view) {
    currentView = view;
    notifyListeners();
  }

  /// ----- LOAD DATA -----
  Future<void> loadGraph() async {
    graphStatus = ViewStatus.loading;
    notifyListeners();

    try {
      final res = await dio.get("$NEO4J_API_URL/graph", data: {
        "user_id": "550e8400-e29b-41d4-a716-446655440000",
        "graph_id": "550e8400-e29b-41d4-a716-446655440000",
        "project_id": "550e8400-e29b-41d4-a716-446655440000",
      });

      nodes = parseNodes(res.data["nodes"]);
      edges = parseEdges(res.data["edges"]);

      generateLabelColors();

      graphStatus = ViewStatus.loaded;
    } catch (e) {
      graphStatus = ViewStatus.error;
    }

    notifyListeners();
  }

  // get actions for a given label
  Map<String, String> getActionsForLabel(String label) {
    final response = dio.get("$AUTH_API_URL/action-map");
    final actionMap = <String, String>{};
    response.then((res) {
      final data = res.data as Map<String, dynamic>;
      if (data.containsKey(label)) {
        data[label].forEach((key, value) {
          actionMap[key] = value;
        });
      }
    }).catchError((error) {
      debugPrint("Error fetching action map: $error");
    });
    return actionMap;
  }

  // get nodes grouped by label
  Map<String, List<Map<String, dynamic>>> getNodesGroupedByLabel() {
    final Map<String, List<Map<String, dynamic>>> groupedNodes = {};

    for (final node in nodes) {
      final label = node.labels.isNotEmpty ? node.labels[0] : 'Unknown';
      if (!groupedNodes.containsKey(label)) {
        groupedNodes[label] = [];
      }
      groupedNodes[label]!.add({
        'id': node.id,
        'properties': node.properties,
      });
    }

    return groupedNodes;
  }

  /// ----- DELETE EVERYTHING -----
  Future<void> deleteAllNodes() async {
    try {
      await dio.delete("$NEO4J_API_URL/delete_all");

      nodes.clear();
      edges.clear();
      selectedNodeIds.clear();

      notifyListeners();
    } catch (e) {
      print("Delete error: $e");
    }
  }

  Future<void> loadTable() async {
    tableStatus = ViewStatus.loading;
    notifyListeners();

    try {
      final res = await dio.get("$NEO4J_API_URL/nodes");
      nodes = parseNodes(res.data);
      tableStatus = ViewStatus.loaded;
      switchTo("table");
    } catch (e) {
      tableStatus = ViewStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadHierarchy() async {
    hierarchyStatus = ViewStatus.loading;
    notifyListeners();

    try {
      final res = await dio.get("$NEO4J_API_URL/hierarchy");

      nodes = parseNodes(res.data["nodes"]);
      edges = parseEdges(res.data["edges"]);

      hierarchyStatus = ViewStatus.loaded;
    } catch (e) {
      hierarchyStatus = ViewStatus.error;
    }

    notifyListeners();
  }

  /// ----- COLOR ASSIGNMENT -----
  void generateLabelColors() {
    labelColors.clear();
    final uniqueLabels = nodes.map((n) => n.labels[0]).toSet().toList();

    for (var i = 0; i < uniqueLabels.length; i++) {
      labelColors[uniqueLabels[i]] =
          Colors.primaries[i % Colors.primaries.length];
    }
  }

  /// ----- FILTERING -----
  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updatePropertyFilter(String key, dynamic value) {
    propertyFilters[key] = value;
    notifyListeners();
  }

  List<Node> get filteredNodes {
    return nodes.where((n) {
      if (searchQuery.isNotEmpty &&
          !n.labels[0].toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      for (final entry in propertyFilters.entries) {
        if (n.properties[entry.key] != entry.value) return false;
      }

      return true;
    }).toList();
  }
}
