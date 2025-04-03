import 'package:flutter/material.dart';
import 'package:final_project/graph/graph_provider.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  List<String> nodeLabels = [];
  List<String> edgeLabels = [];
  Map<String, Color> colors= {};
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure Provider is accessed after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final graphProvider = Provider.of<GraphProvider>(context, listen: false);
      setState(() {
        nodeLabels = [...List<String>.from(graphProvider.nodeLabels)];
        edgeLabels = [...List<String>.from(graphProvider.edgeLabels)];
        colors = graphProvider.labelColors;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevents unnecessary space
      children: [
        // Search bar
        SearchBar(
          // shape: WidgetStatePropertyAll(OutlinedBorder),
          controller: controller,
          elevation: WidgetStateProperty.all(0),
          autoFocus: true,
          hintText: "Filter by label or properties",
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              onPressed: () => controller.clear(),
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Filter chips inside a GridView
        if(nodeLabels.isNotEmpty)
          Text("Nodes", maxLines: 1,style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            children: List.generate(nodeLabels.length, (int index){
              return FilterChip(
                backgroundColor: colors[nodeLabels[index]],
                label: Text(nodeLabels[index]), // Fix: Wrap in Text()
                onSelected: (bool selected) {
                  // Handle filter selection
                },
              );
            }),
          ),
        if(edgeLabels.isNotEmpty)
          Text("Relationships", maxLines: 1,style: TextStyle(fontSize: 18), textAlign: TextAlign.left,),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            children: List.generate(edgeLabels.length, (int index){
              return FilterChip(
                backgroundColor: colors[edgeLabels[index]],
                label: Text(edgeLabels[index]), // Fix: Wrap in Text()
                onSelected: (bool selected) {
                  // Handle filter selection
                },
              );
            }),
          )
      ],
    );
  }
}
