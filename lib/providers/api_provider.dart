import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> entities = [];

  Future<void> loadEntities() async {
    try {
      if(entities.isNotEmpty) return;
      final response = await _apiService.fetchEntities();
      entities = response.data;
      print(entities);
      notifyListeners();
    } catch (e) {
      print('Error loading entities: $e');
    }
  }

  Future<void> executeTransform(String entityId, String sourceName, String query) async {
    try {
      await _apiService.runTransform(entityId, sourceName, query);
      notifyListeners();
    } catch (e) {
      print('Error executing transform: $e');
    }
  }
}
