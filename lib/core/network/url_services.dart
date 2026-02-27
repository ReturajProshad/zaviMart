class UrlServices {
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String login = '/auth/login';
  static const String users = '/users';

  static const String refreshToken = '/auth/refresh'; // Placeholder

  // --- Product Endpoints ---
  static const String products = '/products';
  static String productsByCategory(String id) => '/products/$id';
  static const String categories = '/products/categories';
}
