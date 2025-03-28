part of 'graph_view.dart';

class TableView extends StatefulWidget {
  const TableView({super.key});

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final graphData = Provider.of<GraphProvider>(context);
    final groupedNodes = graphData.getNodesGroupedByLabel();

    return ListView(
      children: groupedNodes.entries.map((entry) {
        return ExpansionTile(
          title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
          children: entry.value.map((node) {
            return ListTile(
              title: Text(node['properties']['name'] ?? 'Unnamed Node'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Type: ${node['labels']?.join(', ') ?? 'Unknown'}"),
                  if (node.containsKey('relationships') && node['relationships'].isNotEmpty)
                    Text(
                      "🔗 Relationships: " +
                          node['relationships']
                              .map((rel) => "[${rel['type']}] → ${rel['target']}")
                              .join(', '),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}