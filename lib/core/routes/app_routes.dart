import 'package:go_router/go_router.dart';
import 'package:zavimart/features/auth/presentation/view/auth_view.dart';

final router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => LoginPage(),
    ),
  ],
);

class AppRoutes {
  static const login = '/';
}
