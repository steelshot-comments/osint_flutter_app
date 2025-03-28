part of 'graph_view.dart';

class NodeDetailsPanel extends StatefulWidget {
  final Map<String, dynamic> node;
  final VoidCallback onClose;

  const NodeDetailsPanel({required this.node, required this.onClose, Key? key})
      : super(key: key);

  @override
  _NodeDetailsPanelState createState() => _NodeDetailsPanelState();
}

class _NodeDetailsPanelState extends State<NodeDetailsPanel> {
  bool isMinimized = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Color based on theme
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents unnecessary space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Always Visible)
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
                    Text("ID: ${widget.node['id']}"),
                    Text("Label: ${widget.node['label']}"),
                    // Text("Type: ${widget.node['type']}"),
                    SizedBox(height: 8),
                    Text("Properties:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.node['properties'].entries.map(
                      (e) => Text("${e.key}: ${e.value}"),
                    ),
                    Divider(),
                    Text("Available Transforms:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: widget.node['transforms']
                          .map<Widget>((transform) => Column(
                                children: [
                                  TransformButton(
                                    nodeId: widget.node['id'],
                                    text: transform,
                                  ),
                                  SizedBox(
                                      height:
                                          8), // Space between button and status
                                  TransformStatusWidget(
                                    nodeId: widget.node['id'],
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
