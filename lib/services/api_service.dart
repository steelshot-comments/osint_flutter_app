import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.0.114:8000'));

  Future<Response> fetchEntities() async {  
    try {
      final response = await _dio.get('/results');
      print(response.data);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch entities');
    }
  }

  Future<Response> runTransform(String entityId, String sourceName, String query) async {
    try {
      return await _dio.post('/run/$sourceName/$query',);
    } catch (e) {
      throw Exception('Failed to run transform');
    }
  }
}
