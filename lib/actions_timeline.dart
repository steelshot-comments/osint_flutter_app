import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TimelinesPage extends StatefulWidget {
  const TimelinesPage({super.key});

  @override
  _TimelinesPageState createState() => _TimelinesPageState();
}

class _TimelinesPageState extends State<TimelinesPage> {
  List<dynamic> timelineData = [];
  bool isLoading = true;
  final PRODUCTION_FASTAPI_URL = dotenv.env['PRODUCTION_FASTAPI_URL'];
  final FASTAPI_URL = dotenv.env['FASTAPI_URL'];

  @override
  void initState() {
    super.initState();
    fetchTimelines();
  }

  Future<void> fetchTimelines() async {
    try {
      var response = await Dio().get('$FASTAPI_URL/task-results');
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
      await Dio().delete('$FASTAPI_URL/delete-task-result/$id');
      setState(() {
        // print(timelineData.length);
        timelineData.removeWhere((item) {
          print(item['id']);
          print(id);
          return item['id'] == id;
        });
        // print(timelineData.length);
      });
    } catch (e) {
      print('Error deleting transform: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('History of actions'),
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : timelineData.length != 0
                ? ListView.builder(
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
                            onPressed: () =>
                                deleteTransform(item['id'].toString()),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text("No results in timeline")));
  }
}
