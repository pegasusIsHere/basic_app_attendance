// lib/core/network/endpoints.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Endpoints {
  // Override at build time with: --dart-define=API_BASE_URL=https://api.example.com
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api', // Android emulator localhost
  );

  // Paths
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
}

final baseUrlProvider = Provider<String>((_) => Endpoints.defaultBaseUrl);
  