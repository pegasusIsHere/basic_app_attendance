// lib/features/auth/presentation/providers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/refresh_token.dart';
import '../../domain/usecases/register.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RefreshTokenUseCase _refresh;
  final LogoutUseCase _logout;
  final Future<User> Function() _fetchMe;

  AuthController({
    required LoginUseCase login,
    required RegisterUseCase register,
    required RefreshTokenUseCase refresh,
    required LogoutUseCase logout,
    required Future<User> Function() fetchMe,
  })  : _login = login,
        _register = register,
        _refresh = refresh,
        _logout = logout,
        _fetchMe = fetchMe,
        super(const AuthUnknown());

  Future<void> bootstrap() async {
    state = const AuthLoading();
    try {
      // try refresh → fetchMe
      await _refresh();
      final user = await _fetchMe();
      state = AuthAuthenticated(user);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final (user, _) = await _login(email: email, password: password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthUnauthenticated(message: e.toString());
    }
  }

  Future<void> register(String email, String password, {String? name}) async {
    state = const AuthLoading();
    try {
      final (user, _) = await _register(email: email, password: password, name: name);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthUnauthenticated(message: e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }
}
