import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TransformButton extends StatelessWidget {
  final String nodeId;
  final String text;

  const TransformButton({super.key, required this.nodeId, required this.text});

  void startTransform() async {
    debugPrint("DEBUG: Sending transform request for node $nodeId");
    try {
      await Dio().post("http://192.168.0.114:8000/start_transform/$nodeId");
      debugPrint("DEBUG: Transform request sent successfully. Connecting WebSocket...");
    } catch (e) {
      debugPrint("Error starting transform: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: startTransform,
      child: Text(text),
    );
  }
}
