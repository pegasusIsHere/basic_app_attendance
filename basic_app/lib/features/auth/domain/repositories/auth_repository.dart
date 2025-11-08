// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/user.dart';

abstract class AuthRepository {
  Future<(User user, String accessToken)> login({
    required String email,
    required String password,
  });

  Future<(User user, String accessToken)> register({
    required String email,
    required String password,
    String? name,
  });

  Future<String> refreshToken();

  Future<User> fetchMe(); // profile/me

  Future<void> logout();
}
  