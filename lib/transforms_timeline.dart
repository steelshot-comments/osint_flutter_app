import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TimelinesPage extends StatefulWidget {
  const TimelinesPage({super.key});

  @override
  _TimelinesPageState createState() => _TimelinesPageState();
}

class _TimelinesPageState extends State<TimelinesPage> {
  List<dynamic> timelineData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTimelines();
  }

  Future<void> fetchTimelines() async {
    try {
      var response = await Dio().get('http://192.168.0.114:8000/results');
      setState(() {
        timelineData = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching timelines: $e');
    }
  }

  Future<void> deleteTransform(String id) async {
    try {
      await Dio().delete('http://localhost/results/$id');
      setState(() {
        timelineData.removeWhere((item) => item['id'] == id);
      });
    } catch (e) {
      print('Error deleting transform: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timelines')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: timelineData.length,
              itemBuilder: (context, index) {
                var item = timelineData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['source'] ?? 'Unknown Tool'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Query: ${item['query']}'),
                        Text('Result: ${item['result']}'),
                        Text('Timestamp: ${item['timestamp']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTransform(item['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
