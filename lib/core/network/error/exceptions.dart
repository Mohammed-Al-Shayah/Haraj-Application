import 'package:dio/dio.dart';
import 'error_model.dart';
import 'dart:developer';

class ServerException implements Exception {}

class CacheException implements Exception {}

class Exceptions {
  static ErrorModel handleDioException(DioException e) {
    final response = e.response;

    if (response != null && response.data is Map<String, dynamic>) {
      try {
        return ErrorModel.fromJson(response.data);
      } catch (error) {
        log("Error parsing response: $error");
        log("Response data: ${response.data}");
        throw ServerException();
      }
    }

    log("DioException: ${e.message}");
    throw Exception('Unhandled error: ${e.message}');
  }
}
