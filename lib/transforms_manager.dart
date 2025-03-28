import 'package:flutter/material.dart';

class TransformsManagerPage extends StatefulWidget {
  @override
  _TransformsManagerPageState createState() => _TransformsManagerPageState();
}

class _TransformsManagerPageState extends State<TransformsManagerPage> {
  List<Map<String, dynamic>> transforms = [
    {'id': 1, 'type': 'Person', 'name': 'John Doe', 'details': {'Age': '30', 'Gender': 'Male'}},
    {'id': 2, 'type': 'Phone Number', 'name': '+123456789', 'details': {'Carrier': 'XYZ Telecom'}},
    {'id': 3, 'type': 'Location', 'name': 'New York', 'details': {'Coordinates': '40.7128° N, 74.0060° W'}},
    {'id': 4, 'type': 'Social Media Account', 'name': '@johndoe', 'details': {'Platform': 'Twitter'}},
    {'id': 5, 'type': 'Transaction', 'name': 'Transaction #123', 'details': {'Amount': '500', 'Date': '2025-03-10'}},
  ];

  void _addEntity(String type, String name, Map<String, String> details) {
    setState(() {
      transforms.add({'id': transforms.length + 1, 'type': type, 'name': name, 'details': details});
    });
  }

  void _editEntity(int index, String name, Map<String, String> details) {
    setState(() {
      transforms[index]['name'] = name;
      transforms[index]['details'] = details;
    });
  }

  void _deleteEntity(int index) {
    setState(() {
      transforms.removeAt(index);
    });
  }

  void _showEntityDialog({int? index}) {
    final _nameController = TextEditingController(
        text: index != null ? transforms[index]['name'] : '');
    final Map<String, TextEditingController> _detailControllers = {};

    if (index != null) {
      transforms[index]['details'].forEach((key, value) {
        _detailControllers[key] = TextEditingController(text: value);
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Entity' : 'Edit Entity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
              ..._detailControllers.entries.map((entry) => TextField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: entry.key),
                  )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                final name = _nameController.text;
                final details = {for (var entry in _detailControllers.entries) entry.key: entry.value.text};
                if (index == null) {
                  _addEntity('Custom', name, details);
                } else {
                  _editEntity(index, name, details);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('transforms')),
      body: ListView.builder(
        itemCount: transforms.length,
        itemBuilder: (context, index) {
          final entity = transforms[index];
          return ListTile(
            title: Text('${entity['type']}: ${entity['name']}'),
            subtitle: Text(entity['details'].entries.map((e) => '${e.key}: ${e.value}').join(', ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _showEntityDialog(index: index)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteEntity(index)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntityDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
