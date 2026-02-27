import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/providers/api_service_provider.dart';
import 'package:zavimart/features/products/data/datasources/product_remote_datasource.dart';
import 'package:zavimart/features/products/data/repositories/product_repo_impl.dart';
import 'package:zavimart/features/products/domain/entities/category.dart';
import 'package:zavimart/features/products/domain/entities/product.dart';
import 'package:zavimart/features/products/domain/repositories/product_repo.dart';
import 'package:zavimart/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:zavimart/features/products/domain/usecases/get_products_usecase.dart';

final productRepoProvider = Provider<ProductRepo>((ref) {
  final dataSource = ProductRemoteDataSourceImpl(ref.read(apiServiceProvider));
  return ProductRepoImpl(dataSource);
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.read(productRepoProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(productRepoProvider));
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  final String? _category;

  ProductsNotifier(this._category);

  @override
  Future<List<Product>> build() async {
    return _fetch(_category);
  }

  Future<List<Product>> _fetch(String? category) async {
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(category: category);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }

  Future<void> filterByCategory(String? category) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(category: category);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => AsyncValue.data(r),
    );
  }
}

final productsProvider =
    AsyncNotifierProvider.family<ProductsNotifier, List<Product>, String?>(
      (category) => ProductsNotifier(category),
    );

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return _fetch();
  }

  Future<List<Category>> _fetch() async {
    final result = await ref.read(getCategoriesUseCaseProvider).call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) => categories,
    );
  }

  Future<void> refetch() async {
    state = const AsyncValue.loading();
    final result = await ref.read(getCategoriesUseCaseProvider).call();
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => AsyncValue.data(r),
    );
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );
