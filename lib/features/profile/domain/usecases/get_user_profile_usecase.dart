import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';

class GetUserProfileUseCase {
  final AuthRepo _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<Failure, User>> call(int userId) async {
    return await _repository.getUserProfile(userId);
  }
}
