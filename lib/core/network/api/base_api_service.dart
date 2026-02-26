import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/core/network/api/api_client.dart';

abstract class BaseApiService {
  final ApiClient _apiClient = ApiClient();
  String _extractMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return 'Server Error';
  }

  Future<Either<Failure, Response<T>>> handleApiCall<T>(
    Future<Response<T>> apiCall,
  ) async {
    try {
      final response = await apiCall;
      return Right(response);
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }

      final message = _extractMessage(e.response?.data);

      if (status == 401 || status == 403) {
        return Left(UnauthorizedFailure(message));
      }

      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return handleApiCall(
      _apiClient.get<T>(path, queryParameters: queryParameters),
    );
  }

  Future<Either<Failure, Response<T>>> post<T>(String path, {dynamic data}) {
    return handleApiCall(_apiClient.post<T>(path, data: data));
  }
}
