part of 'investigation_page.dart';

class NodeDetailsPanel extends StatefulWidget {
  final Map<String, dynamic> nodeDetails;
  final VoidCallback onClose;

  const NodeDetailsPanel(
      {super.key, required this.nodeDetails, required this.onClose});

  @override
  _NodeDetailsPanelState createState() => _NodeDetailsPanelState();
}

class _NodeDetailsPanelState extends State<NodeDetailsPanel> {
  bool isMinimized = false;

  void _deleteNode() async {
    await Dio().delete(
      "$NEO4J_API_URL/delete-node/${widget.nodeDetails["id"]}",
    );
    // remove node from graph
    context.read<GraphProvider>().removeNodes([widget.nodeDetails["id"]]);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.nodeDetails['label'];
    final actionMap = context.watch<GraphProvider>().getActionsForLabel(label);
    // print("-------------------------- $actionMap -----------------------");

    return Container(
      // Color based on theme
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Node Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isMinimized = !isMinimized;
                    });
                  },
                  icon: Icon(isMinimized ? Icons.add : Icons.minimize),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          // Content (Only Visible When Not Minimized)
          if (!isMinimized)
            SizedBox(
              height: 200, // Keeps content scrollable within a fixed height
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ID: ${widget.nodeDetails['id']}"),
                    Text("Label: $label"),
                    SizedBox(height: 8),
                    Text("Properties:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.nodeDetails['properties'].entries.map(
                      (e) => Text("${e.key}: ${e.value}"),
                    ),
                    Divider(),
                    ...[
                      if (actionMap != null) ...[
                        Text(
                          "Available Transforms:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ...((actionMap as List).map<Widget>((action) {
                          // print("actionnnnnnnnnnnnnnn: $action");
                          print(action["queryField"]);
                          final queryValue = widget.nodeDetails['properties'][action["queryField"]];
                          return TransformButton(
                            text: action["label"] ?? 'No Label',
                            nodeID: widget.nodeDetails["id"],
                            source: action["tool"] ?? 'Unknown',
                            query: queryValue?? "Empty",
                          );
                        }).toList()),
                      ]
                    ],
                    SquircleButton(
                      onTap: _deleteNode,
                      title: "Delete",
                      background: Colors.red,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
