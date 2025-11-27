part of '../investigation_page.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  Map<String, dynamic>? selectedNode;
  late final WebViewController _controller = WebViewController();

  void onMessage(JavaScriptMessage message) {
    Map<String, dynamic> nodeData =
        Map<String, dynamic>.from(jsonDecode(message.message));
    setState(() {
      selectedNode = nodeData;
    });
  }

  void showNodeDetails(Map<String, dynamic> node) {
    setState(() {
      selectedNode = node;
    });
  }

  void closeNodeDetails() {
    setState(() {
      selectedNode = null;
    });
  }

  void searchGraph(query, filter) {
    final finalQuery = jsonEncode(query);
    final finalFilter = jsonEncode(filter);
    _controller.runJavaScript("window.searchGraph($finalQuery, $finalFilter)");
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = Provider.of<GraphProvider>(context, listen: false);

    return CustomWebView(
      assetUrl: 'assets/web/graph.html',
      onMessage: onMessage,
      controller: _controller,
      data: {
        'nodes': graphProvider.nodes,
        'edges': graphProvider.edges,
      },
    );
  }
}
