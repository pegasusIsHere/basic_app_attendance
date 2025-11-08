// lib/features/auth/presentation/providers/auth_providers.dart
import 'package:basic_app/core/network/endpoints.dart';
import 'package:basic_app/shared/providers/http_client_provider.dart';
import 'package:basic_app/shared/providers/storage_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/datasources/auth_local_ds.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/refresh_token.dart';
import '../../domain/usecases/register.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';
import 'auth_controller.dart';

final _authLocalDSProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(
    read: (k) => storage.read(key: k),
    write: (k, v) => storage.write(key: k, value: v),
    delete: (k) => storage.delete(key: k),
  );
});

final _authRemoteDSProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(baseUrlProvider);
  return AuthRemoteDataSourceImpl(dio as Dio, baseUrl: baseUrl);
});

final _authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(_authRemoteDSProvider),
    local: ref.watch(_authLocalDSProvider),
  );
});

final _loginUCProvider = Provider((ref) => LoginUseCase(ref.watch(_authRepoProvider)));
final _registerUCProvider = Provider((ref) => RegisterUseCase(ref.watch(_authRepoProvider)));
final _refreshUCProvider = Provider((ref) => RefreshTokenUseCase(ref.watch(_authRepoProvider)));
final _logoutUCProvider = Provider((ref) => LogoutUseCase(ref.watch(_authRepoProvider)));
final _fetchMeProvider = Provider<Future<User> Function()>((ref) {
  return () => ref.read(_authRepoProvider).fetchMe();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(
          login: ref.watch(_loginUCProvider),
          register: ref.watch(_registerUCProvider),
          refresh: ref.watch(_refreshUCProvider),
          logout: ref.watch(_logoutUCProvider),
          fetchMe: ref.watch(_fetchMeProvider),
        ));
