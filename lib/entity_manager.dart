import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/graph/graph_provider.dart';

class AddNodePage extends StatefulWidget {
  @override
  _AddNodePageState createState() => _AddNodePageState();
}

class _AddNodePageState extends State<AddNodePage> {
  List<NodeForm> nodes = [NodeForm(onRemove: () {})];

  void addCard() {
    setState(() {
      nodes.add(NodeForm(onRemove: () => removeCard(nodes.length - 1)));
    });
  }

  void removeCard(int index) {
    if (index >= 0 && index < nodes.length) {
      setState(() {
        nodes.removeAt(index);
      });
    }
  }

  void submitNodes() {
    List<Map<String, dynamic>> nodeData = [];
    // for (var node in nodes) {
    //   if (!node.validateAndFocus()) {
    //     return;
    //   }
    //   nodeData.add(node.getNodeData());
    // }
    Provider.of<GraphProvider>(context, listen: false).addNodes(nodeData);
    setState(() {
      nodes = [NodeForm(onRemove: () {})];
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Nodes")),
      body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: nodes.length,
                
                itemBuilder: (context, index) => nodes[index],
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: addCard,
                  child: Text("Add Another Node"),
                ),
                ElevatedButton(
                  onPressed: submitNodes,
                  child: Text("Submit"),
                ),
              ],
            )
          ],
        ),
    );
  }
}

class NodeForm extends StatefulWidget {
  final VoidCallback onRemove;

  const NodeForm({required this.onRemove});

  @override
  _NodeFormState createState() => _NodeFormState();

  bool validateAndFocus() => _NodeFormState().validateAndFocus();
  Map<String, dynamic> getNodeData() => _NodeFormState().getNodeData();
}

class _NodeFormState extends State<NodeForm> {
  bool isExpanded = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  List<Map<String, TextEditingController>> properties = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void addProperty() {
    setState(() {
      properties.add({
        "name": TextEditingController(),
        "value": TextEditingController(),
      });
    });
  }

  void removeProperty(int index) {
    setState(() {
      properties.removeAt(index);
    });
  }

  bool validateAndFocus() {
    if (nameController.text.trim().isEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
      return false;
    }
    if (labelController.text.trim().isEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
      return false;
    }
    for (var property in properties) {
      if (property["name"]!.text.trim().isEmpty ||
          property["value"]!.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(FocusNode());
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> getNodeData() {
    return {
      "name": nameController.text.trim(),
      "label": labelController.text.trim(),
      "properties": properties
          .map((p) => {
                "name": p["name"]!.text.trim(),
                "value": p["value"]!.text.trim()
              })
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = Provider.of<GraphProvider>(context);

    return ExpansionTile(
      initiallyExpanded: true,
      title: Text("New node"),
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: widget.onRemove,
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                      validator: (value) =>
                          value!.trim().isEmpty ? "Required" : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: labelController.text.isEmpty
                          ? null
                          : labelController.text,
                      onChanged: (value) {
                        setState(() {
                          labelController.text = value ?? "";
                        });
                      },
                      onSaved: (value) {
                        labelController.text = value ?? "";
                      },
                      items: graphProvider.nodeLabels.map((label) {
                        return DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Label",
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: List.generate(properties.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: properties[index]["name"],
                                decoration:
                                    InputDecoration(labelText: "Property Name"),
                                validator: (value) =>
                                    value!.trim().isEmpty ? "Required" : null,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: properties[index]["value"],
                                decoration:
                                    InputDecoration(labelText: "Property Value"),
                                validator: (value) =>
                                    value!.trim().isEmpty ? "Required" : null,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => removeProperty(index),
                            ),
                          ],
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: addProperty,
                      child: Text("Add Property"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
