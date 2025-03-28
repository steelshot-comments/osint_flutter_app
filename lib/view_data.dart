import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Neo4j Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DashboardButton(label: 'Add Node', route: AddNodeScreen()),
            DashboardButton(label: 'View Data', route: ViewDataScreen()),
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String label;
  final Widget route;

  DashboardButton({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => route));
        },
        child: Text(label),
      ),
    );
  }
}

class AddNodeScreen extends StatefulWidget {
  @override
  _AddNodeScreenState createState() => _AddNodeScreenState();
}

class _AddNodeScreenState extends State<AddNodeScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', type = '', extraInfo = '';

  Future<void> addNode() async {
    final response = await http.post(
      Uri.parse('http://localhost:5500/add-record'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'type': type, 'extraInfo': extraInfo}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Node added successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding node')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Node')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (val) => name = val,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Type (Victim, Trafficker, etc.)'),
                onChanged: (val) => type = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Extra Info'),
                onChanged: (val) => extraInfo = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: addNode, child: Text('Add Node')),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewDataScreen extends StatefulWidget {
  @override
  _ViewDataScreenState createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  List<dynamic> nodes = [];

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://localhost:5500/view-nodes'));
    if (response.statusCode == 200) {
      // debugPrint(jsonDecode(response.body));
      setState(() {
        nodes = jsonDecode(response.body)['nodes'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Data')),
      body: ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          var node = nodes[index];
          var labels = node['labels'].join(', '); // Join labels as a string
          var properties = node['properties']
              .entries
              .map((e) => "${e.key}: ${e.value}")
              .join('\n'); // Convert properties to a readable format

          return ListTile(
            title: Text(labels), // Display node labels
            subtitle: Text(properties), // Display node properties
          );
        },
      ),
    );
  }
}
