import 'package:zavimart/features/auth/domain/entities/address_entity.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';

class GeolocationModel extends Geolocation {
  const GeolocationModel({required super.lat, required super.long});

  factory GeolocationModel.fromJson(Map<String, dynamic> json) {
    return GeolocationModel(lat: json['lat'] ?? '', long: json['long'] ?? '');
  }
}

class AddressModel extends Address {
  const AddressModel({
    required super.city,
    required super.street,
    required super.number,
    required super.zipcode,
    required super.geolocation,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? 0,
      zipcode: json['zipcode'] ?? '',
      geolocation: GeolocationModel.fromJson(json['geolocation'] ?? {}),
    );
  }
}

class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    required super.name,
    super.username,
    super.phone,
    super.address,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'],
      name:
          '${json['name']?['firstname'] ?? ''} ${json['name']?['lastname'] ?? ''}',
      username: json['username'] ?? '',
      phone: json['phone'],
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
    );
  }

  factory UserModel.fromTokenJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['sub']?.toString() ?? '0',
      email: json['email'] ?? json['user'] ?? '',
      name: json['name'] ?? json['user'] ?? '',
      username: json['user'] ?? '',
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      username: username,
      phone: phone,
      address: address,
      createdAt: createdAt,
    );
  }
}
