import 'dart:convert';
import 'dart:io';

import 'package:final_project/components/button.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/graph/graph_provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
    int id = 1;
    final Uri url =
        Uri.parse("http://192.168.0.114:5500/add-record/${id}/${id}/${id}");
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
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isExpanded = true;

  String? selectedLabel;
  Map<String, TextEditingController> propertyControllers = {};
  File? selectedFile;

  final Map<String, List<String>> predefinedProperties = {
    "Phone Number": ["Number", "Country"],
    "IP Address": ["IP", "ISP"],
    "Domain": ["Domain", "Registrar"],
    "Email": ["Email", "Provider"],
    "Person": ["Name", "Age"],
    "Account": ["Username", "Platform"],
    "File": ["File Name"],
  };

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
        propertyControllers["File Name"]?.text = file.path.split('/').last;
      });
    }
  }

  void removeProperty(String key) {
    setState(() {
      propertyControllers.remove(key);
    });
  }

  bool validateAndFocus() {
    if (selectedLabel == null || selectedLabel!.isEmpty) return false;

    for (var controller in propertyControllers.values) {
      if (controller.text.trim().isEmpty) return false;
    }

    return true;
  }

  Map<String, dynamic> getNodeData() {
    return {
      "labels": [selectedLabel],
      "properties": {
        for (var entry in propertyControllers.entries)
          entry.key: entry.value.text.trim()
      }
    };
  }

  void initializeProperties(String label) {
    propertyControllers.clear();
    for (var prop in predefinedProperties[label] ?? []) {
      propertyControllers[prop] = TextEditingController();
    }
    if (label == "File") {
      selectedFile = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      title: Text("New node"),
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: widget.onRemove,
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLabel,
                  onChanged: (value) {
                    setState(() {
                      selectedLabel = value;
                      initializeProperties(value!);
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Label",
                      fillColor: Color.fromRGBO(247, 255, 255, 1),
                      filled: true,
                      border: InputBorder.none),
                  items: predefinedProperties.keys.map((label) {
                    return DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                ...propertyControllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(
                              labelText: entry.key,
                              border: OutlineInputBorder()),
                          validator: (value) =>
                              value!.trim().isEmpty ? "Required" : null,
                          readOnly: selectedLabel == "File" &&
                              entry.key == "File Name", // prevent editing
                          onTap: selectedLabel == "File" &&
                                  entry.key == "File Name"
                              ? pickFile
                              : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => removeProperty(entry.key),
                        icon: Icon(Icons.delete_outline_rounded),
                      ),
                    ]),
                  );
                }),
                // SquircleButton(
                //   onTap: () {
                //     setState(() {
                //       final newKey =
                //           "Property ${propertyControllers.length + 1}";
                //       propertyControllers[newKey] = TextEditingController();
                //     });
                //   },
                //   title: "Add property",
                //   background: Color.fromRGBO(247, 255, 255, 1),
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
