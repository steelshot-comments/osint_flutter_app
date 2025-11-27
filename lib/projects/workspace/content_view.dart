part of 'investigation_page.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveView();
    });
  }

  @override
  void didUpdateWidget(ContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _updateActiveView();
    }
  }

  void _updateActiveView() {
    final webviews = Provider.of<WebViewProvider>(context, listen: false);
    switch (widget.selectedIndex) {
      case 0:
        webviews.switchActiveView("graph");
        break;
      case 1:
        webviews.switchActiveView("map");
        break;
      case 2:
        webviews.switchActiveView("table");
        break;
    }
  }

  Widget _buildErrorDialog(GraphProvider graphProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Error fetching graph data: Cannot connect to the server",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => graphProvider.loadGraph(),
                child: const Text("Try again"),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                child: const Text("Go back"),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tabs(
        onTabChanged: (index) {
          // Handle tab change if needed, e.g. update provider
        },
        tabContentBuilder: (index) {
          return Stack(
            children: [
              Positioned.fill(child: Consumer<GraphProvider>(
                builder: (context, graphProvider, child) {
                  if (graphProvider.graphStatus == ViewStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (graphProvider.graphStatus == ViewStatus.loaded) {
                    switch (widget.selectedIndex) {
                      case 0:
                        return WebView();
                      case 1:
                        return MapView();
                      case 2:
                        return TableView();
                      default:
                        return const Center(child: Text("Error"));
                    }
                  } else {
                    return _buildErrorDialog(graphProvider);
                  }
                },
              )),
              // if (selectedNode != null)
              //   Positioned(
              //     bottom: 0,
              //     left: 0,
              //     right: 0,
              //     child: NodeDetailsPanel(
              //       nodeDetails: selectedNode!,
              //       onClose: closeNodeDetails,
              //     ),
              //   ),
              // if (graphProvider.isFilterPanelVisible)
              //   FilterPanel(
              //     searchGraph: searchGraph,
              //   ),
            ],
          );
        },
      ),
    );
  }
}