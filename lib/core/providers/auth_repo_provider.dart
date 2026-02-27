import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/providers/api_service_provider.dart';
import 'package:zavimart/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:zavimart/features/auth/domain/repositories/auth_repo.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthRepoImpl(apiService);
});
