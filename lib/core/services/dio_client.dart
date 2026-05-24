import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'secure_storage.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[REQUEST] ${options.method} ${options.uri}');
            debugPrint('[HEADERS] ${options.headers}');
            debugPrint('[DATA] ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[RESPONSE] ${response.statusCode}');
            debugPrint('[DATA] ${response.data}');
          }

          handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            debugPrint('[ERROR] ${error.response?.statusCode}');
            debugPrint('[MESSAGE] ${error.message}');
            debugPrint('[DATA] ${error.response?.data}');
          }

          if (error.response?.statusCode == 401) {
            await SecureStorageService.clearAll();
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
