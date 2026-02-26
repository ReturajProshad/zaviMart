import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepo {
  Future<Either<Failure, User>> login(String email, String password);
}
