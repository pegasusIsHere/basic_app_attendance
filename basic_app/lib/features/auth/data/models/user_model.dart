// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    // allow both _id / id
    final id = (j['_id'] ?? j['id']) as String;
    return UserModel(
      id: id,
      email: j['email'] as String,
      role: j['role'] as String? ?? 'user',
      name: j['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
      };
}
