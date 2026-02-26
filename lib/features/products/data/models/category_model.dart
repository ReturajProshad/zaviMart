import 'package:zavimart/features/products/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.name, super.image});

  // The Fake Store API returns a list of strings for categories
  factory CategoryModel.fromString(String categoryName) {
    return CategoryModel(name: categoryName);
  }
}
