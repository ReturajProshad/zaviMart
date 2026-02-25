// core/api/base_api_service.dart
import 'package:dio/dio.dart';
import 'package:zavimart/core/network/api/api_client.dart';
import 'package:zavimart/core/network/api/api_exception.dart';

abstract class BaseApiService {
  final ApiClient _apiClient = ApiClient();

  Future<Response<T>> handleApiCall<T>(Future<Response<T>> apiCall) async {
    try {
      final response = await apiCall;

      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) {
        return response;
      }

      throw ApiException(
        message: "Unexpected server response status: $status",
        statusCode: status,
        details: response.data,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      String errorMessage = "Unknown network error";

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            "Connection timeout. Please check your internet connection.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "No internet connection.";
      } else if (e.response?.data is Map &&
          e.response?.data['message'] != null) {
        // Use server's specific message if available
        errorMessage = e.response?.data['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      throw ApiException(
        message: errorMessage,
        statusCode: status,
        details: e.response?.data,
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return handleApiCall(
      _apiClient.get<T>(path, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return handleApiCall(_apiClient.post<T>(path, data: data));
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return handleApiCall(_apiClient.put<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path) {
    return handleApiCall(_apiClient.delete<T>(path));
  }

  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
  }) {
    return handleApiCall(
      _apiClient.upload<T>(path, data: data, onSendProgress: onSendProgress),
    );
  }
}
