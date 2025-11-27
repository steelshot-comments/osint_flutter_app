// models/graph_models.dart
part of 'graph_provider.dart';

class Node {
  final String id;
  final List<String> labels;
  final Map<String, dynamic> properties;

  Node({
    required this.id,
    required this.labels,
    required this.properties,
  });

  /// Convenience getters
  String get primaryLabel => labels.isNotEmpty ? labels.first : 'Uncategorized';
  String get name {
    // common name fields
    final nameKeys = ['name', 'label', 'title'];
    for (final k in nameKeys) {
      if (properties.containsKey(k) && properties[k] != null) {
        return properties[k].toString();
      }
    }
    return id;
  }

  factory Node.fromMap(Map<String, dynamic> map) {
    // Accept either {id, labels, properties} or {id, label, props...}
    final id = (map['id'] ?? map['nodeId'] ?? map['uuid'] ?? '').toString();

    // labels might be string, list or missing
    List<String> labels;
    if (map['labels'] is List) {
      labels = List<String>.from(map['labels'].map((e) => e.toString()));
    } else if (map['labels'] is String) {
      labels = [map['labels']];
    } else if (map['label'] is String) {
      labels = [map['label']];
    } else {
      labels = [];
    }

    // properties might be nested under 'properties' or be the whole map
    Map<String, dynamic> properties = {};
    if (map['properties'] is Map) {
      properties = Map<String, dynamic>.from(map['properties']);
    } else {
      // remove common fields and take the rest as properties
      properties = Map<String, dynamic>.from(map)
        ..remove('id')
        ..remove('nodeId')
        ..remove('uuid')
        ..remove('labels')
        ..remove('label')
        ..remove('properties');
    }

    return Node(id: id.isEmpty ? UniqueKey().toString() : id, labels: labels, properties: properties);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labels': labels,
        'properties': properties,
      };
}

class Edge {
  final String id;
  final String source;
  final String target;
  final String? label;
  final Map<String, dynamic> properties;

  Edge({
    required this.id,
    required this.source,
    required this.target,
    this.label,
    required this.properties,
  });

  factory Edge.fromMap(Map<String, dynamic> map) {
    // Accept variations: {id, source, target, label, properties}
    final id = (map['id'] ?? map['edgeId'] ?? map['uuid'] ?? '').toString();
    final source = (map['source'] ?? map['from'] ?? map['start'] ?? '').toString();
    final target = (map['target'] ?? map['to'] ?? map['end'] ?? '').toString();
    final label = (map['label'] ?? map['type'] ?? map['relationship'])?.toString();

    Map<String, dynamic> properties = {};
    if (map['properties'] is Map) {
      properties = Map<String, dynamic>.from(map['properties']);
    } else {
      properties = Map<String, dynamic>.from(map)
        ..remove('id')
        ..remove('edgeId')
        ..remove('uuid')
        ..remove('source')
        ..remove('from')
        ..remove('start')
        ..remove('target')
        ..remove('to')
        ..remove('end')
        ..remove('label')
        ..remove('type')
        ..remove('relationship')
        ..remove('properties');
    }

    return Edge(
      id: id.isEmpty ? UniqueKey().toString() : id,
      source: source,
      target: target,
      label: label,
      properties: properties,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'target': target,
        'label': label,
        'properties': properties,
      };
}

/// Parse raw API response into Node list.
///
/// Accepts:
/// - List<Map>
/// - List of nested Neo4j shapes
List<Node> parseNodes(dynamic raw) {
  if (raw == null) return [];

  // If raw already a list
  if (raw is List) {
    return raw
        .map((e) {
          try {
            if (e is Map<String, dynamic>) return Node.fromMap(e);
            // handle e being a list [id, labels, props] (less common)
            if (e is List && e.length >= 3) {
              final id = e[0].toString();
              final labelsRaw = e[1];
              final props = e[2] is Map ? Map<String, dynamic>.from(e[2]) : <String, dynamic>{};
              final labels = labelsRaw is List ? List<String>.from(labelsRaw.map((x) => x.toString())) : <String>[];
              return Node(id: id, labels: labels, properties: props);
            }
          } catch (_) {}
          return null;
        })
        .whereType<Node>()
        .toList();
  }

  // If raw is a map that contains nodes
  if (raw is Map && raw['nodes'] is List) {
    return parseNodes(raw['nodes']);
  }

  return [];
}

/// Parse raw API response into Edge list.
List<Edge> parseEdges(dynamic raw) {
  if (raw == null) return [];

  if (raw is List) {
    return raw
        .map((e) {
          try {
            if (e is Map<String, dynamic>) return Edge.fromMap(e);
            // handle [id, source, target, props] shape
            if (e is List && e.length >= 4) {
              final id = e[0].toString();
              final source = e[1].toString();
              final target = e[2].toString();
              final props = e[3] is Map ? Map<String, dynamic>.from(e[3]) : <String, dynamic>{};
              return Edge(id: id, source: source, target: target, label: null, properties: props);
            }
          } catch (_) {}
          return null;
        })
        .whereType<Edge>()
        .toList();
  }

  if (raw is Map && raw['edges'] is List) {
    return parseEdges(raw['edges']);
  }

  return [];
}
