// lib/features/auth/domain/usecases/login.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repo;
  LoginUseCase(this.repo);

  Future<(User user, String accessToken)> call({
    required String email,
    required String password,
  }) {
    return repo.login(email: email, password: password);
  }
}
