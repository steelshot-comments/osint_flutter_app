import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewProvider extends ChangeNotifier {
  final Map<String, WebViewController> _controllers = {};
  String activeView = "graph";

  bool isSelectionMode = false;
  String currentLayout = "cose";

  // Register controller by type
  void registerController(String key, WebViewController controller) {
    _controllers[key] = controller;
  }

  // Get current controller
  WebViewController? get controller => _controllers[activeView];

  WebViewController? getController(String key) => _controllers[key];

  void switchActiveView(String key) {
    activeView = key;
    notifyListeners();
  }

  void reload() {
    controller?.reload();
  }

  void runJs(String js) {
    controller?.runJavaScript(js);
  }

  void changeLayout(String layout) {
    currentLayout = layout;
    controller?.runJavaScript("window.switchToLayout('$layout')");
    notifyListeners();
  }

  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    controller?.runJavaScript(
      "window.cy.boxSelectionEnabled($isSelectionMode)",
    );
    notifyListeners();
  }
}