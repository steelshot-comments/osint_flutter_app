import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class PoliciesPage extends StatefulWidget {
  const PoliciesPage({super.key});
  @override
  _PoliciesPageState createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  String markdownData = "";

  @override
  void initState() {
    super.initState();
    loadMarkdown();
  }

  Future<void> loadMarkdown() async {
    final String data = await rootBundle.loadString('assets/policies/policies.md');
    setState(() {
      markdownData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: markdownData.isEmpty
          ? Center(child: Text("Oops! Our lawyers must be on vacation. No policies found — proceed at your own risk!"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Markdown(data: markdownData),
            ),
    );
  }
}
