import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepo repo;

  LoginUseCase(this.repo);

  Future<Either<Failure, User>> call(String email, String password) {
    return repo.login(email, password);
  }
}
