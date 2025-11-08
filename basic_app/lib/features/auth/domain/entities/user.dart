// lib/features/auth/domain/entities/user.dart
class User {
  final String id;
  final String email;
  final String? name;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });
}
