// lib/features/auth/domain/usecases/register.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repo;
  RegisterUseCase(this.repo);

  Future<(User user, String accessToken)> call({
    required String email,
    required String password,
    String? name,
  }) {
    return repo.register(email: email, password: password, name: name);
  }
}
