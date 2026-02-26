import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/core/network/api/base_api_imple.dart';
import 'package:zavimart/core/network/url_services.dart';
import 'package:zavimart/core/services/prefs_service.dart';
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

      if (token == null) {
        return Left(ServerFailure('Token not found'));
      }
      await PrefsService().saveTokens(token, '');
      final user = User(id: '0', email: username, name: username);

      return Right(user);
    });
  }
}
