import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final double price;
  final String description;
  final String category;
  final String image;
  final String title;
  final int id;
  final Rating rating;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, title, price];
}

class Rating extends Equatable {
  final double rate;
  final int count;

  const Rating({required this.rate, required this.count});

  @override
  List<Object?> get props => [rate, count];
}
