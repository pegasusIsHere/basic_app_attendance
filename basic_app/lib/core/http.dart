
import 'package:dio/dio.dart';
import 'env.dart';

Dio buildDio() {
  final dio = Dio(BaseOptions(
    baseUrl:"http://localhost:3000/api",// Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'Content-Type': 'application/json'},
  ));
  return dio;
}
