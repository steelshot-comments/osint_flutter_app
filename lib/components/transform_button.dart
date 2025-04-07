import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TransformButton extends StatefulWidget {
  final String text;
  final String source;
  final String query;
  final String nodeID;

  const TransformButton({
    super.key,
    required this.text,
    required this.source,
    required this.query,
    required this.nodeID,
  });

  @override
  State<TransformButton> createState() => _TransformButtonState();
}

class _TransformButtonState extends State<TransformButton> {
  bool _isLoading = false;
  WebSocketChannel? _channel;

  void startTransform() async {
    setState(() => _isLoading = true);
    debugPrint("DEBUG: Sending transform request for node");

    try {
      // Send POST request
      await Dio().post(
        "http://192.168.0.114:8000/run/${widget.source}",
        data: {
          "query": widget.query,
          "node_id": widget.nodeID,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      debugPrint("DEBUG: Transform request sent. Connecting to WebSocket...");

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse("ws://192.168.0.114:8000/ws/transforms/${widget.nodeID}"),
      );

      // Listen for WebSocket messages
      _channel!.stream.listen(
        (message) {
          debugPrint("DEBUG: WebSocket message: $message");
          setState(() => _isLoading = false);
          _channel?.sink.close();
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      debugPrint("Error starting transform: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : startTransform,
      child: Text(widget.text),
    );
  }
}