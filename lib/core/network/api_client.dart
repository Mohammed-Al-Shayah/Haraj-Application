import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'error/exceptions.dart';

class ApiClient {
  final Dio client;

  ApiClient({required this.client}) {
    // Log HTTP traffic for debugging.
    final alreadyHasLogger = client.interceptors.any(
      (it) => it is LogInterceptor,
    );
    if (!alreadyHasLogger) {
      client.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          // ignore: avoid_print
          logPrint: (obj) => print(obj),
        ),
      );
    }
  }

  Future<Options> _getDefaultOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString('_accessToken') ?? prefs.getString('_loginToken') ?? '';
    String language = prefs.getString('language') ?? 'en';

    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': language,
      },
    );
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      options ??= await _getDefaultOptions();
      final response = await client.get(
        url,
        queryParameters: queryParams,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isMultipart = false,
  }) async {
    try {
      Options finalOptions = options ?? await _getDefaultOptions();

      if (isMultipart) {
        finalOptions = finalOptions.copyWith(
          contentType: 'multipart/form-data',
        );
      }

      final response = await client.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: finalOptions,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isMultipart = false,
  }) async {
    try {
      Options finalOptions = options ?? await _getDefaultOptions();

      if (isMultipart) {
        finalOptions = finalOptions.copyWith(
          contentType: 'multipart/form-data',
        );
      }

      final response = await client.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: finalOptions,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      options ??= await _getDefaultOptions();
      final response = await client.put(url, data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      options ??= await _getDefaultOptions();
      final response = await client.delete(url, data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String url, {
    required Map<String, dynamic> data,
    required File file,
    String fileFieldName = 'avatar',
  }) async {
    try {
      Options options = await _getDefaultOptions();
      FormData formData = FormData.fromMap({
        ...data,
        fileFieldName: await MultipartFile.fromFile(file.path),
      });

      final response = await client.post(url, data: formData, options: options);
      return response.data;
    } on DioException catch (e) {
      throw Exceptions.handleDioException(e);
    }
  }
}
