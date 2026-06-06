import 'package:attend_ease/core/network/api_config.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class ApiService {
  /// Set this once at app startup. Called whenever any API call receives a
  /// 401 Unauthorized — clear storage and push the user back to login.
  static VoidCallback? onUnauthorized;

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout:
          const Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout:
          const Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (o) => debugPrint('[API] $o'),
    ));
  }

  // Messages the server middleware sends for real auth failures.
  static const _authErrorMessages = {'No token provided', 'Invalid or expired token'};

  Future<ApiResponse<T>> handleRequest<T>(
    Future<Response> Function() requestFactory,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await requestFactory();
      if (response.statusCode == 401) {
        final msg = response.data?['message']?.toString() ?? '';
        if (_authErrorMessages.contains(msg)) {
          onUnauthorized?.call();
          return ApiResponse.error('Session expired. Please log in again.',
              statusCode: 401);
        }
        // Business-logic 401 (e.g. "Employee not registered") — just surface the message.
        return ApiResponse.error(msg.isNotEmpty ? msg : 'Request failed',
            statusCode: 401);
      }
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return ApiResponse.fromJson(response.data, fromJson);
      }
      return ApiResponse.error(
        response.data?['message']?.toString() ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Options? _authOptions(String? token) {
    if (token == null || token.isEmpty) return null;
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<ApiResponse<T>> get<T>(
    String url, {
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) {
    return handleRequest(
        () => _dio.get(url,
            queryParameters: queryParameters,
            options: _authOptions(token)),
        fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String url, {
    T Function(dynamic)? fromJson,
    dynamic data,
    String? token,
  }) {
    return handleRequest(
        () => _dio.post(url, data: data, options: _authOptions(token)),
        fromJson);
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.response?.statusCode == 401) {
      final msg = e.response?.data?['message']?.toString() ?? '';
      if (_authErrorMessages.contains(msg)) {
        onUnauthorized?.call();
        return ApiResponse.error('Session expired. Please log in again.',
            statusCode: 401);
      }
      return ApiResponse.error(msg.isNotEmpty ? msg : 'Unauthorized',
          statusCode: 401);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error('Connection timed out', statusCode: 408);
      case DioExceptionType.connectionError:
        return ApiResponse.error('No internet connection');
      default:
        final msg = e.response?.data?['message']?.toString() ??
            e.message ??
            'Unknown error';
        return ApiResponse.error(msg, statusCode: e.response?.statusCode);
    }
  }
}
