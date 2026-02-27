import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String city;
  final String street;
  final int number;
  final String zipcode;
  final Geolocation geolocation;

  const Address({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    required this.geolocation,
  });

  @override
  List<Object?> get props => [city, street, number, zipcode, geolocation];
}

class Geolocation extends Equatable {
  final String lat;
  final String long;

  const Geolocation({required this.lat, required this.long});

  @override
  List<Object?> get props => [lat, long];
}
