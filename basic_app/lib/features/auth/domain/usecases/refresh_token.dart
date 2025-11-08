// lib/features/auth/domain/usecases/refresh_token.dart
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repo;
  RefreshTokenUseCase(this.repo);

  Future<String> call() => repo.refreshToken();
}
