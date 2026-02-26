import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/products/domain/entities/category.dart';
import 'package:zavimart/features/products/domain/entities/product.dart';

abstract class ProductRepo {
  Future<Either<Failure, List<Product>>> getProducts({String? category});
  Future<Either<Failure, List<Category>>> getCategories();
}
