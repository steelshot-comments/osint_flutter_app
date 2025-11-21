import 'dart:io';

import 'package:knotwork/components/button.dart';
import 'package:knotwork/projects/graph/graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class EditNodePage extends StatefulWidget {
  const EditNodePage({super.key, required this.nodes});

  final List<Map<String, dynamic>> nodes;

  @override
  _EditNodePageState createState() => _EditNodePageState();
}

class _EditNodePageState extends State<EditNodePage> {
  List<GlobalKey<_NodeFormState>> nodeKeys = [];
  List<NodeForm> nodes = [];

  @override
  void initState() {
    super.initState();

    // Initialize one NodeForm for each node in widget.nodes
    for (var node in widget.nodes) {
      final key = GlobalKey<_NodeFormState>();
      nodeKeys.add(key);
      nodes.add(NodeForm(
        key: key,
        onRemove: () => removeCard(nodes.indexWhere((n) => n.key == key)),
        initialLabel: node["labels"] != null && node["labels"].isNotEmpty
            ? node["labels"].first
            : null,
        initialProperties: Map<String, dynamic>.from(node["properties"] ?? {}),
      ));
    }

    // fallback: if no nodes are passed, create an empty one
    if (nodes.isEmpty) {
      final key = GlobalKey<_NodeFormState>();
      nodeKeys.add(key);
      nodes.add(NodeForm(onRemove: () {}, key: key));
    }
  }

  void removeCard(int index) {
    if (index >= 0 && index < nodes.length) {
      setState(() {
        nodeKeys.removeAt(index);
        nodes.removeAt(index);
      });
    }
  }

  void _submitNodes() async {
    final String url = "$FASTAPI_URL/add-record";
    List<Map<String, dynamic>> nodeData = [];
    for (final key in nodeKeys) {
      final state = key.currentState;

      if (state == null) {
        debugPrint("State is null");
        continue;
      }
      if (!state.validateAndFocus()) {
        nodeData = [];
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Node details are not valid")));
        return;
      }

      if (state.selectedLabel == "File" && state.selectedFile != null) {
        try {
          final file = state.selectedFile!;
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(file.path),
          });

          final response = await Dio().post(
            "$FASTAPI_URL/upload-file",
            data: formData,
            options: Options(
              headers: {
                "Content-Type": "multipart/form-data",
              },
            ),
          );

          if (response.statusCode != 200) {
            throw Exception("File upload failed");
          }

          // Optional: handle server response
          final uploadedFileUrl = response.data['file_url'];
          debugPrint("File uploaded: $uploadedFileUrl");
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File upload failed: $e")),
          );
          return;
        }
      }

      nodeData.add(state.getNodeData());
    }

    try {
      final response = await Dio().post(
        url,
        options: Options(headers: {"Content-Type": "application/json"}),
        data: nodeData,
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
      appBar: AppBar(title: Text("Edit Nodes")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              itemCount: nodes.length,
              itemBuilder: (context, index) => nodes[index],
            ),
          ),
          SquircleButton(
            onTap: _submitNodes,
            title: "Submit",
            widthMode: SquircleButtonWidth.wrapContent,
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}

class NodeForm extends StatefulWidget {
  final VoidCallback onRemove;
  final GlobalKey<_NodeFormState> key;
  final String? initialLabel;
  final Map<String, dynamic>? initialProperties;

  const NodeForm({
    required this.onRemove,
    required this.key,
    this.initialLabel,
    this.initialProperties,
  }) : super(key: key);

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
    "Email": ["address", "provider"],
    "Person": ["Name", "Age"],
    "Account": ["Username", "Platform"],
    "File": ["File Name"],
  };

  @override
  void initState() {
    super.initState();
    selectedLabel = widget.initialLabel;

    // Initialize controllers with existing values (if any)
    if (widget.initialProperties != null) {
      widget.initialProperties!.forEach((key, value) {
        propertyControllers[key] =
            TextEditingController(text: value.toString());
      });
    } else if (selectedLabel != null) {
      initializeProperties(selectedLabel!);
    }
  }

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
      },
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
      title: Text(selectedLabel ?? "Node"),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: widget.onRemove,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  
                  initialValue: selectedLabel,
                  onChanged: null,
                  decoration: const InputDecoration(
                    labelText: "Label",
                    filled: true,
                    border: InputBorder.none,
                  ),
                  items: predefinedProperties.keys.map((label) {
                    return DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ...propertyControllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: entry.key,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.trim().isEmpty ? "Required" : null,
                            readOnly: selectedLabel == "File" &&
                                entry.key == "File Name",
                            onTap: selectedLabel == "File" &&
                                    entry.key == "File Name"
                                ? pickFile
                                : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => removeProperty(entry.key),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
