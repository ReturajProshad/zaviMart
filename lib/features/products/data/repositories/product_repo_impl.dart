import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/features/products/data/datasources/product_remote_datasource.dart';
import 'package:zavimart/features/products/domain/entities/category.dart';
import 'package:zavimart/features/products/domain/entities/product.dart';
import 'package:zavimart/features/products/domain/repositories/product_repo.dart';

class ProductRepoImpl implements ProductRepo {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepoImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? category}) {
    return remoteDataSource
        .getProducts(category: category)
        .then(
          (response) => response.fold((l) => Left(l), (r) {
            // Cast List<ProductModel> to List<Product>
            final List<Product> products = r.map((model) => model).toList();
            return Right(products);
          }),
        );
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() {
    return remoteDataSource.getCategories().then(
      (response) => response.fold((l) => Left(l), (r) {
        // Cast List<CategoryModel> to List<Category>
        final List<Category> categories = r.map((model) => model).toList();
        return Right(categories);
      }),
    );
  }
}
