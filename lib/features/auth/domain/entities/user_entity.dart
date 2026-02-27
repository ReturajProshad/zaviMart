import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String name;
  final String username;
  final DateTime? createdAt;

  const User({
    required this.id,
    this.email,
    required this.name,
    this.username = '',
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, email!, name, username, createdAt!];
}
