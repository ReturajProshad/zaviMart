import 'package:equatable/equatable.dart';
import 'package:zavimart/features/auth/domain/entities/address_entity.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String name;
  final String username;
  final String? phone;
  final Address? address;
  final DateTime? createdAt;

  const User({
    required this.id,
    this.email,
    required this.name,
    this.username = '',
    this.phone,
    this.address,
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? phone,
    Address? address,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    username,
    phone,
    address,
    createdAt,
  ];
}
