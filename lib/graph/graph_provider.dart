import 'package:flutter/material.dart';

class GraphProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _nodes = [];
  List<String> _nodeLabels = [
    "Person",
    "Trafficker",
    "Victim",
    "Client",
    "Phone number",
    "Transcation"
  ];
  List<Map<String, dynamic>> _edges = [];
  List<String> _edgeLabels = [
    "Uses",
    "Has phone",
    "Goes to",
    "paid",
    "visited"
  ];
  final Map<String, Color> _labelColors = {
    "Person": Colors.blue,
    "Trafficker": Colors.red,
    "Victim": Colors.yellow,
    "Client": Colors.teal,
    "Phone number": Colors.pink,
    "Transcation": Colors.amber,
    "Uses": Colors.lime,
    "Has phone": Colors.deepOrange,
    "Goes to": Colors.indigo,
    "paid": Colors.deepPurple,
    "visited": Colors.blueGrey
  };

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

  void addNodes(List<Map<String, dynamic>> nodes){
    _nodes.addAll(nodes);
  }

  void setLabels(
      List<Map<String, dynamic>> nodes, List<Map<String, dynamic>> edges) {
    for (var node in nodes) {
      for (var label in node['labels'] ?? []) {
        if (!_nodeLabels.contains(label)) {
          _nodeLabels.add(label);
        }
      }
    }
    // for (var edge in edges) {
    //   for (var label in edge['labels']) {
    //     if (!_edgeLabels.contains(label)) {
    //       _edgeLabels.add(label);
    //     }
    //   }
    // }
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
      List<String> labels = node['label'] is List<dynamic> ? List<String>.from(node['label']) : [];

      if (labels.isEmpty) {
        labels = ['Uncategorized']; // Default if no label exists
      }

      for (var label in labels) {
        groupedNodes.putIfAbsent(label, () => []).add(node);
      }
    }

    return groupedNodes;
  }
}
