import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  // getters

  bool get hasFetchedOnce => _hasFetchedOnce;
  List<Map<String, dynamic>> get nodes => _nodes;
  List<String> get nodeLabels => _nodeLabels;
  List<Map<String, dynamic>> get edges => _edges;
  List<String> get edgeLabels => _edgeLabels;
  Map<String, Color> get labelColors => _labelColors;

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
      _edges.removeWhere((edge) => edge['source'] == id || edge['target'] == id);
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
        labels = ['Uncategorized']; // Default if no label exists
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
    try {
      final response = await Dio().get("http://192.168.0.114:8000/action-map");
      final data = Map<String, dynamic>.from(response.data);
      // print("----------------- $data -----------------------");
      _actionMap.clear();
      data.forEach((key, value) {
        _actionMap[key] = List<Map<String, String>>.from(
          (value as List).map((e) => Map<String, String>.from(e)),
        );
      });
      notifyListeners();
    } catch (e) {
      print("Failed to load action map: $e");
    }
  }
}
