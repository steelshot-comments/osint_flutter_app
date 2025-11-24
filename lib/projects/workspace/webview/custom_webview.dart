import 'dart:convert';
import 'package:knotwork/providers/graph/graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:webview_all/webview_all.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JSMessageCallback = void Function(JavaScriptMessage message);

class CustomWebView extends StatefulWidget {
  final String assetUrl;
  final JSMessageCallback onMessage;
  dynamic controller;

  CustomWebView(
      {super.key,
      required this.assetUrl,
      required this.onMessage,
      required this.controller});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  @override
  void initState() {
    super.initState();
    // Convert JSON to a string, escaping special characters
    final jsonData =
        jsonEncode(Provider.of<GraphProvider>(context, listen: false).toJson());
    final escapedJson = jsonEncode(jsonData);

    // if (!Platform.isLinux) {
    widget.controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterGraphChannel',
        onMessageReceived: widget.onMessage,
      )
      ..loadFlutterAsset(widget.assetUrl);
    widget.controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          widget.controller
              .runJavaScript("window.updateGraphData($escapedJson)");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: widget.controller);
  }
}
