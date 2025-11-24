part of 'investigation_page.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  late GraphProvider graphProvider;

  Widget _buildErrorDialog() {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Error fetching graph data: Cannot connect to the server",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => {
                  graphProvider.setLoading(true),
                  graphProvider.fetchAndSetProvider()
                },
                child: Text("Try again"),
              ),
              TextButton(
                onPressed: () =>
                    {Navigator.of(context).pushReplacementNamed('/home')},
                child: Text("Go back"),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    graphProvider = Provider.of<GraphProvider>(context, listen: false);
    final webviews = Provider.of<WebViewProvider>(context);
    int selectedIndex = widget.selectedIndex;

    return Expanded(
      child: Tabs(
        tabContentBuilder: (index) {
          return Stack(
            children: [
              Positioned.fill(child: Builder(
                builder: (context) {
                  if (graphProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (graphProvider.hasData) {
                    switch (selectedIndex) {
                      case 0:
                        webviews.switchActiveView("graph");
                        return WebView();
                      case 1:
                        webviews.switchActiveView("map");
                        return MapView();
                      case 2:
                        webviews.switchActiveView("table");
                        return TableView();
                      default:
                        return Center(child: Text("Error"));
                    }
                  } else {
                    return _buildErrorDialog();
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
