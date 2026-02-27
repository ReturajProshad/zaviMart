import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/core/network/api/base_api_imple.dart';
import 'package:zavimart/core/network/url_services.dart';
import 'package:zavimart/core/services/secure_storage_service.dart';
import 'package:zavimart/features/auth/data/models/user_model.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final BaseApiServiceImpl apiService;

  AuthRepoImpl(this.apiService);

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    final result = await apiService.post<Map<String, dynamic>>(
      UrlServices.login,
      data: {'username': username, 'password': password},
    );

    return result.fold((failure) => Left(failure), (response) async {
      final token = response.data?['token'];
      if (token == null) return Left(ServerFailure('Token not found'));

      try {
        await SecureStorageService().saveTokens(token, '');
        final user = UserModel.fromTokenJson(_decodeToken(token)).toEntity();
        return Right(user);
      } catch (e) {
        return Left(ServerFailure('Failed to process token: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await SecureStorageService().getAccessToken();
      if (token == null) return Left(ServerFailure('No token found'));
      if (_isTokenExpired(token)) {
        await SecureStorageService().clear();
        return Left(ServerFailure('Token expired'));
      }
      final user = UserModel.fromTokenJson(_decodeToken(token)).toEntity();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile(int userId) async {
    final result = await apiService.get<Map<String, dynamic>>(
      '${UrlServices.users}/$userId',
    );

    return result.fold((failure) => Left(failure), (response) {
      final userData = response.data;
      if (userData == null) {
        return Left(ServerFailure('User data not found'));
      }
      try {
        final user = UserModel.fromJson(userData).toEntity();
        return Right(user);
      } catch (e) {
        return Left(ServerFailure('Failed to parse user data: $e'));
      }
    });
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    final payload = parts[1];
    String normalizedPayload = payload;
    while (normalizedPayload.length % 4 != 0) {
      normalizedPayload += '=';
    }

    final decoded = utf8.decode(base64Url.decode(normalizedPayload));
    return json.decode(decoded) as Map<String, dynamic>;
  }

  bool _isTokenExpired(String token) {
    try {
      final decoded = _decodeToken(token);
      final exp = decoded['exp'];
      if (exp == null) return false;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }
}
