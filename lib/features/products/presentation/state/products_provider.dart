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
  late GetProductsUseCase _getProductsUseCase;

  @override
  Future<List<Product>> build() async {
    _getProductsUseCase = ref.read(getProductsUseCaseProvider);
    return _loadProducts(null);
  }

  Future<List<Product>> _loadProducts(String? category) async {
    final result = await _getProductsUseCase(category: category);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }

  Future<void> filterByCategory(String? category) async {
    state = const AsyncValue.loading();
    final result = await _getProductsUseCase(category: category);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => AsyncValue.data(r),
    );
  }
}

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  late GetCategoriesUseCase _getCategoriesUseCase;

  @override
  Future<List<Category>> build() async {
    _getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);
    return _loadCategories();
  }

  Future<List<Category>> _loadCategories() async {
    final result = await _getCategoriesUseCase();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) => categories,
    );
  }

  // *** FIX: Add a public refetch method for the RefreshIndicator ***
  Future<void> refetch() async {
    state = const AsyncValue.loading();
    final result = await _getCategoriesUseCase();
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => AsyncValue.data(r),
    );
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  () {
    return ProductsNotifier();
  },
);

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(() {
      return CategoriesNotifier();
    });
