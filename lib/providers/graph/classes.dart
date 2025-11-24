part of 'graph_provider.dart';

class GraphNode {
  final String id;
  final List<String> labels;
  final Map<String, dynamic> properties;

  GraphNode({required this.id, required this.labels, required this.properties});

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json["id"],
      labels: List<String>.from(json["labels"] ?? []),
      properties: json["properties"] ?? {},
    );
  }
}

class GraphEdge {
  final String id;
  final String source;
  final String target;
  final String type;

  GraphEdge({
    required this.id,
    required this.source,
    required this.target,
    required this.type,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      id: json["id"],
      source: json["source"],
      target: json["target"],
      type: json["type"],
    );
  }
}