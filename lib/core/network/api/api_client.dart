import 'dart:developer' as developer;
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zavimart/core/services/secure_storage_service.dart';
import 'package:zavimart/core/network/api/pretty_dio_log.dart';
import 'package:zavimart/core/network/url_services.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initDio();
  }

  late final Dio _dio;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;
  VoidCallback? _logoutCallback;

  void registerLogoutCallback(VoidCallback callback) {
    _logoutCallback = callback;
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: UrlServices.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequestHandler,
        onResponse: _onResponseHandler,
        onError: _onErrorHandler,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          logRequestHeaders: true,
          logRequestBody: true,
          logResponseHeaders: false,
          logResponseBody: true,
        ),
      );
    }
  }

  Future<void> _onRequestHandler(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService().getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    developer.log(
      "API Request: ${options.method} ${options.path}",
      name: "ApiClient",
    );
    handler.next(options);
  }

  Future<void> _onResponseHandler(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    developer.log(
      "API Response: ${response.statusCode} ${response.requestOptions.path}",
      name: "ApiClient",
    );
    handler.next(response);
  }

  Future<void> _onErrorHandler(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    developer.log(
      "API Error: ${err.response?.statusCode} ${err.requestOptions.path}",
      error: err,
      name: "ApiClient",
    );

    final status = err.response?.statusCode;
    final isAuthError = status == 401 || status == 403;

    // 🚫 If refresh token API itself fails → logout immediately
    final isRefreshCall = err.requestOptions.path.contains(
      UrlServices.refreshToken,
    );

    if (isAuthError && isRefreshCall) {
      await _logout();
      return handler.reject(err);
    }

    if (isAuthError && !_isRefreshing) {
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();

      try {
        final refreshed = await refreshToken();
        _refreshCompleter!.complete(refreshed);

        if (refreshed) {
          await _retryRequest(err.requestOptions, handler);
          return;
        } else {
          await _logout(); // 🔥 FIX-2
          return handler.reject(err); // 🔥 STOP CHAIN
        }
      } catch (e) {
        _refreshCompleter?.complete(false);
        await _logout(); // 🔥 FIX-2
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }

    if (isAuthError && _isRefreshing) {
      final refreshed = await _refreshCompleter?.future ?? false;
      if (refreshed) {
        await _retryRequest(err.requestOptions, handler);
        return;
      } else {
        return handler.reject(err);
      }
    }

    _handleApiError(err);
    handler.next(err);
  }

  Future<void> _retryRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final token = await SecureStorageService().getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      handler.reject(e as DioException);
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await SecureStorageService().getRefreshToken();
      if (refreshToken == null) return false;

      developer.log("Refreshing token", name: "ApiClient");
      final response = await Dio().post(
        UrlServices.baseUrl + UrlServices.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken = response.data['data']['refreshToken'];

        await SecureStorageService().saveTokens(
          newAccessToken,
          newRefreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      developer.log("Token refresh failed: $e", name: "ApiClient");
      return false;
    }
  }

  Future<void> _logout() async {
    await SecureStorageService().clear();
    developer.log("Logging out", name: "ApiClient");
    if (_logoutCallback != null) {
      _logoutCallback!();
    }
  }

  void _handleApiError(DioException err) {
    // Don't show UI messages here - let the UI layer handle it
    // Just log the error for debugging
    developer.log("API Error: ${err.message}", name: "ApiClient");
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      onSendProgress: onSendProgress,
      options: options ?? Options(contentType: 'multipart/form-data'),
    );
  }
}
