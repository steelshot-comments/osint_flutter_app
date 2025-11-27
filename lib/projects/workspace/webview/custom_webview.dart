import 'dart:convert';

import 'package:flutter/material.dart';

// import 'package:webview_all/webview_all.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JSMessageCallback = void Function(JavaScriptMessage message);

class CustomWebView extends StatefulWidget {
  final String assetUrl;
  final JSMessageCallback onMessage;
  final WebViewController controller;
  final Map<String, dynamic> data;

  const CustomWebView({
    super.key,
    required this.assetUrl,
    required this.onMessage,
    required this.controller,
    required this.data,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(CustomWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _updateGraphData();
    }
  }

  void _initController() {
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
          _updateGraphData();
        },
      ),
    );
  }

  void _updateGraphData() {
    final escapedJson = jsonEncode(widget.data);
    widget.controller.runJavaScript("window.updateGraphData($escapedJson)");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: widget.controller);
  }
}
