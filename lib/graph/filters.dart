import 'package:flutter/material.dart';
import 'package:final_project/graph/graph_provider.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  Map<String, Color> colors = {};
  TextEditingController controller = TextEditingController();


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
        // ElevatedButton(onPressed: (){context.read<GraphProvider>().notifyListeners();}, child: Text("Press")),
        // Filter chips inside a GridView
        Consumer<GraphProvider>(builder: (context, graphProvider, child) {
          final nodeLabels = graphProvider.nodeLabels;
          final edgeLabels = graphProvider.edgeLabels;
          final colors = graphProvider.labelColors;
          // print("----------- $nodeLabels -------------");  

          if (nodeLabels.isEmpty && edgeLabels.isEmpty) {
            return Text(
                "No labels or edges found"); // or empty container, skeleton loader, etc.
          }

          return Column(
            children: [
              if (nodeLabels.isNotEmpty)
                Text(
                  "Nodes",
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  children: List.generate(nodeLabels.length, (int index) {
                    return FilterChip(
                      backgroundColor: colors[nodeLabels[index]],
                      label: Text(nodeLabels[index]), // Fix: Wrap in Text()
                      onSelected: (bool selected) {
                        // Handle filter selection
                      },
                    );
                  }),
                ),
              if (edgeLabels.isNotEmpty)
                Text(
                  "Relationships",
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                children: List.generate(edgeLabels.length, (int index) {
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
        })
      ],
    );
  }
}
