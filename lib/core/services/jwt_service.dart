import 'dart:convert';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';

class JwtService {
  static Map<String, dynamic> decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    final payload = parts[1];
    String normalizedPayload = payload;
    while (normalizedPayload.length % 4 != 0) {
      normalizedPayload += '=';
    }

    final decoded = utf8.decode(base64Url.decode(normalizedPayload));
    return json.decode(decoded) as Map<String, dynamic>;
  }

  static User createUserFromToken(String token) {
    final decoded = decodeToken(token);
    return User(
      id: decoded['sub']?.toString() ?? '0',
      email: decoded['email'] ?? '',
      name: decoded['name'] ?? decoded['user'] ?? '',
      username: decoded['user'] ?? '',
    );
  }

  static bool isTokenExpired(String token) {
    try {
      final decoded = decodeToken(token);
      final exp = decoded['iat'];
      if (exp == null) return false;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }
}
