import 'package:dartz/dartz.dart';
import 'package:zavimart/core/errors/failures.dart';
import 'package:zavimart/core/network/api/base_api_service.dart';
import 'package:zavimart/core/network/url_services.dart';
import 'package:zavimart/features/products/data/models/category_model.dart';
import 'package:zavimart/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<Either<Failure, List<ProductModel>>> getProducts({String? category});
  Future<Either<Failure, List<CategoryModel>>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final BaseApiService _apiService;

  ProductRemoteDataSourceImpl(this._apiService);

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({String? category}) {
    final path = category != null
        ? '/products/category/$category'
        : UrlServices.products;
    return _apiService
        .get(path)
        .then(
          (response) => response.fold(
            (l) => Left(l),
            (r) => Right(
              (r.data as List)
                  .map((json) => ProductModel.fromJson(json))
                  .toList(),
            ),
          ),
        );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() {
    return _apiService
        .get(UrlServices.categories)
        .then(
          (response) => response.fold(
            (l) => Left(l),
            (r) => Right(
              (r.data as List)
                  .map((json) => CategoryModel.fromString(json as String))
                  .toList(),
            ),
          ),
        );
  }
}
