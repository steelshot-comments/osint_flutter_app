import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class TransformStatusWidget extends StatefulWidget {
  final String nodeId;

  TransformStatusWidget({required this.nodeId});

  @override
  _TransformStatusWidgetState createState() => _TransformStatusWidgetState();
}

class _TransformStatusWidgetState extends State<TransformStatusWidget> {
  final WebSocketService _webSocketService = WebSocketService();
  String status = "waiting";
  Map<String, dynamic>? data;
  bool isFinal = false;

  @override
  void initState() {
    super.initState();
    _webSocketService.connect(widget.nodeId);
    _webSocketService.stream.listen((event) {
      setState(() {
        status = event["status"];
        data = event["data"];

        if (status == "final") {
          isFinal = true;
          _webSocketService.disconnect();
        }
      });
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Status: $status", style: TextStyle(fontSize: 18)),
        if (data != null) 
          Column(
            children: [
              Text("New Nodes: ${data!['new_nodes'] ?? 'N/A'}"),
              Text("New Edges: ${data!['new_edges'] ?? 'N/A'}"),
              if (!isFinal)
                Text("Waiting for Neo4j confirmation...", style: TextStyle(color: Colors.red)),
            ],
          ),
        if (!isFinal) CircularProgressIndicator(),
      ],
    );
  }
}
