import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  // Dev: localhost (web) / 10.0.2.2 (Android emulator)
  // Prod: pass --dart-define=API_URL=https://your-app.onrender.com/api/v1 at build time
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kIsWeb
        ? 'http://localhost:8000/api/v1'
        : 'http://10.0.2.2:8000/api/v1',
  );
  static const String apiKey = 'mobile-app-key'; // Default API key for mobile app
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
  ));

  ApiClient() {
    // Add interceptor for error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle specific error cases
          if (error.response?.statusCode == 429) {
            // Rate limit error
            final retryAfter = error.response?.headers.value('retry-after') ?? 'unknown';
            throw RateLimitException(
              'Rate limit exceeded. Retry after: $retryAfter',
              retryAfter: retryAfter,
            );
          } else if (error.response?.statusCode == 401) {
            // Authentication error
            throw AuthenticationException('Invalid API key or authentication failed');
          } else if (error.response?.statusCode == 400) {
            // Validation error
            final message = error.response?.data['detail'] ?? 'Invalid request';
            throw ValidationException(message);
          } else if (error.response?.statusCode == 500) {
            // Server error
            throw ServerException('Server error: ${error.response?.data['detail'] ?? 'Unknown error'}');
          } else if (error.type == DioExceptionType.connectionTimeout) {
            throw TimeoutException('Connection timeout. Please check your internet connection.');
          } else if (error.type == DioExceptionType.receiveTimeout) {
            throw TimeoutException('Request timeout. Please try again.');
          } else if (error.type == DioExceptionType.connectionError || error.type == DioExceptionType.unknown) {
            // Network connection error - provide user-friendly message
            throw NetworkException('Cannot connect to server. Please check your internet connection and try again.');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final response = await _dio.get('/metadata');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predict(Map<String, dynamic> data, String lang) async {
    try {
      final response = await _dio.post(
        '/predict',
        data: data,
        queryParameters: {'lang': lang},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> smartConsultantPredict(Map<String, dynamic> data, String lang) async {
    try {
      final response = await _dio.post(
        '/smart-consultant',
        data: data,
        queryParameters: {'lang': lang},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class RateLimitException extends ApiException {
  final String retryAfter;
  RateLimitException(String message, {required this.retryAfter}) : super(message);
}

class AuthenticationException extends ApiException {
  AuthenticationException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}
