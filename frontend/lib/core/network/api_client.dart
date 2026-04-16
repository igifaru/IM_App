import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Correct for Android Emulator
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final response = await _dio.get('/metadata');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load metadata: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> predict(Map<String, dynamic> data, String lang) async {
    try {
      final response = await _dio.post('/predict', data: data, queryParameters: {'lang': lang});
      return response.data;
    } catch (e) {
      throw Exception('Prediction failed: ${e.toString()}');
    }
  }
}
