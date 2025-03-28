import 'package:flutter/material.dart';

class GraphProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _nodes = [];
  List<Map<String, dynamic>> _edges = [];
  final Map<String, Color> _labelColors = {};

  List<Map<String, dynamic>> get nodes => _nodes;
  List<Map<String, dynamic>> get edges => _edges;
  Map<String, Color> get labelColors => _labelColors;

  void setGraphData(List<Map<String, dynamic>> nodes, List<Map<String, dynamic>> edges) {
    _nodes = nodes;
    _edges = edges;
    _assignColorsToLabels();
    notifyListeners();
  }

  void _assignColorsToLabels() {
    final availableColors = [
      Colors.blue, Colors.green, Colors.red, Colors.orange,
      Colors.purple, Colors.teal, Colors.indigo, Colors.brown,
      Colors.pink, Colors.cyan, Colors.amber, Colors.lime,
      Colors.lightBlue, Colors.lightGreen, Colors.deepOrange,
      Colors.deepPurple, Colors.blueGrey, Colors.grey,
      Colors.yellow,
    ];

    int colorIndex = 0;
    for (var node in _nodes) {
      for (var label in node['labels'] ?? []) {
        if (!_labelColors.containsKey(label)) {
          _labelColors[label] = availableColors[colorIndex % availableColors.length];
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
      String label = node['label']?.isNotEmpty == true ? node['label'][0] : 'Uncategorized';
      groupedNodes.putIfAbsent(label, () => []).add(node);
    }

    return groupedNodes;
  }
}
