import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  String _wsMessage = ''; // Store latest WebSocket message
  final PRODUCTION_FASTAPI_URL=dotenv.env['PRODUCTION_FASTAPI_URL'];
  final PRODUCTION_WS_FASTAPI_URL=dotenv.env['PRODUCTION_WS_FASTAPI_URL'];

  List<String> nodeTypes = [
    "email",
    "domain",
    "person",
    "phone",
    "ip",
  ];

  void startTransform() async {
    setState(() {
      _isLoading = true;
      _wsMessage = ''; // Clear message on new transform start
    });

    debugPrint("DEBUG: Sending transform request for node");

    try {
      // Send POST request
      await Dio().post(
        "$PRODUCTION_FASTAPI_URL/run/${widget.source}",
        data: {
          "query": widget.query,
          "node_id": widget.nodeID,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      debugPrint("DEBUG: Transform request sent. Connecting to WebSocket...");

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse("$PRODUCTION_WS_FASTAPI_URL/ws/transforms/${widget.nodeID}"),
      );

      // Listen for WebSocket messages
      _channel!.stream.listen(
        (message) {
          debugPrint("DEBUG: WebSocket message: $message");
          setState(() {
            _isLoading = false;
            _wsMessage = message; // Update message display
          });
          _channel?.sink.close();
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          setState(() {
            _isLoading = false;
            _wsMessage = ''; // Clear on error
          });
        },
        onDone: () {
          debugPrint("WebSocket closed.");
          setState(() {
            _wsMessage = ''; // Clear message when closed
          });
        },
      );
    } catch (e) {
      debugPrint("Error starting transform: $e");
      setState(() {
        _isLoading = false;
        _wsMessage = '';
      });
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ElevatedButton(
        onPressed: _isLoading ? null : startTransform,
        child: Text(widget.text),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          _wsMessage,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
