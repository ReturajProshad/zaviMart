import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/providers/auth_repo_provider.dart';
import 'package:zavimart/features/auth/domain/entities/user_entity.dart';
import 'package:zavimart/features/auth/presentation/state/auth_provider.dart';
import 'package:zavimart/features/profile/domain/usecases/get_user_profile_usecase.dart';

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repo = ref.read(authRepoProvider);
  return GetUserProfileUseCase(repo);
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, User>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<User> {
  late final GetUserProfileUseCase _getUserProfileUseCase;

  @override
  Future<User> build() async {
    _getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
    final authState = ref.watch(authProvider);
    final currentUser = authState.when(
      data: (user) => user,
      loading: () => throw Exception('Auth is loading...'),
      error: (error, stack) => throw Exception('Not authenticated'),
    );

    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final userId = int.tryParse(currentUser.id) ?? 0;
    final result = await _getUserProfileUseCase(userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (user) => user,
    );
  }
}
