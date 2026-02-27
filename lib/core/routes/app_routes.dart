import 'package:go_router/go_router.dart';
import 'package:zavimart/features/auth/presentation/view/auth_view.dart';
import 'package:zavimart/features/products/presentation/view/main_listing_page.dart';

final router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.listPage,
      name: AppRoutes.listPage,
      builder: (context, state) => MainListingPage(),
    ),
  ],
);

class AppRoutes {
  static const login = '/';
  static const listPage = '/list';
  static const profilePage = '/profile';
}
