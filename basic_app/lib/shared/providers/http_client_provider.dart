// lib/shared/providers/http_client_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/endpoints.dart';
import 'storage_provider.dart'; // optional, shown below

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  // Optional: attach Authorization header if you store a token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Only if you use secure storage; remove if you don't.
        final storage = ref.read(secureStorageProvider);
        final token = await storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  // Optional logging (disable in prod)
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
