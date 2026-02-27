import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/providers/auth_repo_provider.dart';
import 'package:zavimart/core/routes/app_routes.dart';
import 'package:zavimart/core/services/prefs_service.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';
import 'package:zavimart/features/auth/domain/usecases/login_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.read(authRepoProvider);
  return LoginUseCase(repo);
});

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final LoginUseCase _loginUseCase;
  late final AuthRepo _authRepo;

  @override
  Future<User?> build() async {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _authRepo = ref.read(authRepoProvider);
    final result = await _authRepo.getCurrentUser();
    return result.fold((failure) => null, (user) => user);
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
        router.pushReplacement(AppRoutes.listPage);
      },
    );
  }

  Future<void> logout() async {
    await PrefsService().clear();
    state = const AsyncValue.data(null);
    router.pushReplacement(AppRoutes.login);
  }
}
