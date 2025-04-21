import 'dart:convert';
import 'dart:io';
import 'package:final_project/graph/graph_provider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JSMessageCallback = void Function(JavaScriptMessage message);

class CustomWebView extends StatefulWidget {
  final String assetUrl;
  final JSMessageCallback onMessage;
  dynamic controller;

  // final Function() onControllerReady;

  CustomWebView({
    super.key,
    required this.assetUrl,
    required this.onMessage,
    required this.controller,
    // required this.onControllerReady,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  // void runGraphScript(String script) {
  //   if (Platform.isLinux) {
  //     (_webController as InAppWebViewController?)
  //         ?.evaluateJavascript(source: script);
  //   } else {
  //     (_webController as WebViewController?)?.runJavaScript(script);
  //   }
  // }

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
  // else{
  //   _webController =
  // }
  // }

  @override
  Widget build(BuildContext context) {
    return
        // Platform.isLinux
        // ? InAppWebView(
        //     initialUrlRequest: URLRequest(
        //       url: WebUri("http://localhost:5500/graph.html"),
        //     ),
        //     initialSettings: InAppWebViewSettings(
        //       javaScriptEnabled: true,
        //     ),
        //     onWebViewCreated: (controller) {
        //       _webController = controller;
        //       controller.addJavaScriptHandler(
        //         handlerName: "FlutterGraphChannel",
        //         callback: (args) {
        //           Map<String, dynamic> nodeData =
        //               Map<String, dynamic>.from(Map<String, dynamic>.from(args.first));
        //         },
        //       );
        //       // widget.onControllerReady(_webController);
        //     },
        //   )
        // :
        WebViewWidget(controller: widget.controller);
  }
}
