import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/products/domain/entities/product.dart';
import 'package:zavimart/features/products/domain/repositories/product_repo.dart';

class GetProductsUseCase {
  final ProductRepo repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({String? category}) {
    return repository.getProducts(category: category);
  }
}
