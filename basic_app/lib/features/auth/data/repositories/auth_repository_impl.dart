// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_ds.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<(User, String)> login({required String email, required String password}) async {
    final (tokens, user) = await remote.login(email, password);
    await local.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken);
    return (user, tokens.accessToken);
    }

  @override
  Future<(User, String)> register({required String email, required String password, String? name}) async {
    final (tokens, user) = await remote.register(email, password, name: name);
    await local.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken);
    return (user, tokens.accessToken);
  }

  @override
  Future<String> refreshToken() async {
    final refresh = await local.readRefreshToken();
    if (refresh == null) {
      throw StateError('No refresh token');
    }
    final newAccess = await remote.refresh(refresh);
    await local.saveTokens(access: newAccess, refresh: refresh);
    return newAccess;
  }

  @override
  Future<User> fetchMe() async {
    final access = await local.readAccessToken();
    if (access == null) throw StateError('No access token');
    return await remote.me(access);
  }

  @override
  Future<void> logout() async {
    final refresh = await local.readRefreshToken();
    if (refresh != null) {
      await remote.logout(refresh);
    }
    await local.clearTokens();
  }
}
