import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/graph/graph_provider.dart';
import 'package:http/http.dart' as http;

class AddNodePage extends StatefulWidget {
  const AddNodePage({super.key});
  @override
  _AddNodePageState createState() => _AddNodePageState();
}

class _AddNodePageState extends State<AddNodePage> {
  List<GlobalKey<_NodeFormState>> nodeKeys = [];
  List<NodeForm> nodes = [];

  @override
  void initState() {
    super.initState();
    final key = GlobalKey<_NodeFormState>();
    nodeKeys.add(key);
    nodes.add(NodeForm(onRemove: () {}, key: key));
  }

  void addCard() {
    final key = GlobalKey<_NodeFormState>();
    nodeKeys.add(key);
    setState(() {
      nodes.add(NodeForm(
        onRemove: () => removeCard(nodes.length - 1),
        key: key,
      ));
    });
  }

  void removeCard(int index) {
    if (index >= 0 && index < nodes.length) {
      setState(() {
        nodeKeys.removeAt(index);
        nodes.removeAt(index);
      });
    }
  }

  void submitNodes() async {
    int id=1;
    final Uri url = Uri.parse("http://192.168.0.114:5500/add-record/${id}/${id}/${id}");
    List<Map<String, dynamic>> nodeData = [];
    for (final key in nodeKeys) {
      final state = key.currentState;
      if (state == null) {
        print("State is null");
        continue;
      }
      if (!state.validateAndFocus()) {
        nodeData = [];
        return;
      }
      nodeData.add(state.getNodeData());
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(nodeData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Record added successfully!")),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception("Failed to add record");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: $e")),
      );
    }
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
  final GlobalKey<_NodeFormState> key;

  const NodeForm({required this.onRemove, required this.key}) : super(key: key);

  @override
  _NodeFormState createState() => _NodeFormState();
}

class _NodeFormState extends State<NodeForm> {
  bool isExpanded = true;
  List<Map<String, TextEditingController>> properties = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedLabel = "";

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
    if (selectedLabel!.isEmpty) {
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
    print(selectedLabel);
    return {
      "labels": [selectedLabel],
      "properties": {
        for (var p in properties)
          p["name"]!.text.trim(): p["value"]!.text.trim()
      }
    };
  }

  @override
  Widget build(BuildContext context) {
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
                    Consumer<GraphProvider>(
                      builder: (context, graphProvider, child) {
                        return DropdownButtonFormField<String>(
                          value:
                              graphProvider.nodeLabels.contains(selectedLabel)
                                  ? selectedLabel
                                  : null,
                          onChanged: (value) {
                            setState(() {
                              selectedLabel = value;
                            });
                            print(selectedLabel);
                          },
                          items: graphProvider.nodeLabels.map((label) {
                            return DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: "Labels",
                          ),
                        );
                      },
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
                                decoration: InputDecoration(
                                    labelText: "Property Value"),
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
