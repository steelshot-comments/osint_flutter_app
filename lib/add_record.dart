import 'dart:convert';
import 'dart:io';

import 'package:final_project/components/datefield.dart';
import 'package:flutter/material.dart';
import 'components/image_upload.dart';
import 'components/button.dart';
import 'package:http/http.dart' as http;

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final Uri url = Uri.parse("http://192.168.0.114:5500/add-record");

  Future<void> _submitRecord() async {
    final String name = nameController.text.trim();
    final String number = numberController.text.trim();
    final String location = locationController.text.trim();

    if (name.isEmpty || number.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "number": number,
          "location": location,
          "date": "12/20/2002",
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Record added successfully!")),
        );
        nameController.clear();
        numberController.clear();
        locationController.clear();
        // setState(() {
        //   selectedDate = null;
        // });
      } else {
        throw Exception("Failed to add record");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(label: Text('Name')),
        ),
        TextField(
          controller: numberController,
          decoration: InputDecoration(label: Text('Number')),
        ),
        TextField(
          controller: locationController,
          decoration: InputDecoration(label: Text('Location')),
        ),
        DateInputField(),
        ImageUploader(),
        SquircleButton(onTap: () => {_submitRecord()}, title: "Submit")
      ],
    );
  }
}
