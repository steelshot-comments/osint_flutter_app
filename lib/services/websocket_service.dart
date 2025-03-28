import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  void connect(String nodeId) {
    final uri = Uri.parse("ws://192.168.0.114:8000/ws/transforms/$nodeId");
    print("DEBUG: Connecting to WebSocket: $uri");
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen((message) {
      final decoded = json.decode(message);
      _controller.add(decoded); // Notify listeners
    });
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void disconnect() {
    print("DEBUG: Disconnecting WebSocket.");
    _channel?.sink.close();
    _channel = null;
  }
}
