import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/providers/api_service_provider.dart';
import 'package:zavimart/core/routes/app_routes.dart';
import 'package:zavimart/core/services/prefs_service.dart';
import 'package:zavimart/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';
import 'package:zavimart/features/auth/domain/usecases/login_usecase.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthRepoImpl(apiService);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.read(authRepoProvider);
  return LoginUseCase(repo);
});

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final LoginUseCase _loginUseCase;

  @override
  Future<User?> build() async {
    _loginUseCase = ref.read(loginUseCaseProvider);
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _loginUseCase(email, password);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncValue.data(user);
        router.push(AppRoutes.listPage);
      },
    );
  }

  Future<void> logout() async {
    await PrefsService().clear();
    state = const AsyncValue.data(null);
    router.push(AppRoutes.login);
  }
}
