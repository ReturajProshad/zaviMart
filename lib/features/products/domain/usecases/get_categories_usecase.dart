import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/products/domain/entities/category.dart';
import 'package:zavimart/features/products/domain/repositories/product_repo.dart';

class GetCategoriesUseCase {
  final ProductRepo repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call() {
    return repository.getCategories();
  }
}
