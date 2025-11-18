import 'package:flutter/material.dart';
import 'package:knotwork/projects/graph/graph_provider.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  final Function searchGraph;
  const FilterPanel({super.key, required this.searchGraph});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  Map<String, Color> colors = {};
  TextEditingController controller = TextEditingController();
  List<String> filters = [];

  void search(){
    widget.searchGraph(controller.text, filters);
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
          onChanged: (value) => widget.searchGraph(controller.text, filters),
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

          return SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
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
                      final nodeLabel = nodeLabels[index];
                      return FilterChip(
                        backgroundColor: colors[nodeLabel],
                        label: Text(nodeLabel), // Fix: Wrap in Text()
                        onSelected: (bool selected) {
                          setState(() {
                            if (!filters.contains(nodeLabel)) {
                              filters.add(nodeLabel);
                            }
                            else{
                              filters.remove(nodeLabel);
                            }
                            widget.searchGraph(controller.text, filters);
                          });
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
                      final edgeLabel = edgeLabels[index];
                      return FilterChip(
                        backgroundColor: colors[edgeLabels[index]],
                        label: Text(edgeLabels[index]), // Fix: Wrap in Text()
                        onSelected: (bool selected) {
                          setState(() {
                            if (!filters.contains(edgeLabel)) {
                              filters.add(edgeLabel);
                            }
                            else{
                              filters.remove(edgeLabel);
                            }
                          });
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}
