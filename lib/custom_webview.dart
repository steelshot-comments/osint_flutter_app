import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JSMessageCallback = void Function(JavaScriptMessage message);

class CustomWebView extends StatefulWidget {
  final String assetUrl;
  final void onMessage;
  final Function() onControllerReady;

  const CustomWebView({
    super.key,
    required this.assetUrl,
    required this.onMessage,
    required this.onControllerReady,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  dynamic _webController;
  
  void runGraphScript(String script) {
    if (Platform.isLinux) {
      (_webController as InAppWebViewController?)?.evaluateJavascript(source: script);
    } else {
      (_webController as WebViewController?)?.runJavaScript(script);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!Platform.isLinux) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterGraphChannel',
          onMessageReceived: (msg) {
            // widget.onMessage(msg);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) => widget.onControllerReady(),
          ),
        )
        ..loadFlutterAsset(widget.assetUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    // Platform.isLinux
        // ? InAppWebView(
        //     initialUrlRequest: URLRequest(
        //       url: WebUri("http://localhost:8080/graph.html"),
        //     ),
        //     initialOptions: InAppWebViewGroupOptions(
        //       crossPlatform: InAppWebViewOptions(
        //         javaScriptEnabled: true,
        //       ),
        //     ),
        //     onWebViewCreated: (controller) {
        //       _webController = controller;
        //       controller.addJavaScriptHandler(
        //         handlerName: "FlutterGraphChannel",
        //         callback: (args) {
        //           widget.onMessage(Map<String, dynamic>.from(args.first));
        //         },
        //       );
        //       widget.onControllerReady(_webController);
        //     },
        //   )
        // :
         WebViewWidget(controller: _webController);
  }
}