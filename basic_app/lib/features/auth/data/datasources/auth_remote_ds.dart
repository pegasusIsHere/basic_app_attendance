// lib/features/auth/data/datasources/auth_remote_ds.dart
import 'package:dio/dio.dart';
import '../models/tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(TokensModel tokens, UserModel user)> login(String email, String password);
  Future<(TokensModel tokens, UserModel user)> register(String email, String password, {String? name});
  Future<String> refresh(String refreshToken);
  Future<UserModel> me(String accessToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final String _baseUrl; // e.g. http://localhost:3000/api  (no trailing slash)

  AuthRemoteDataSourceImpl(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  @override
  Future<(TokensModel, UserModel)> login(String email, String password) async {
    try {
      final res = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
      );

      final data = _asMap(res.data);
      final tokens = _tokensFromResponse(data);

      // If backend didn’t include user, fetch it using the fresh access token.
      final user = data['user'] is Map<String, dynamic>
          ? UserModel.fromJson(_asMap(data['user']))
          : await me(tokens.accessToken);

      return (tokens, user);
    } on DioException catch (e) {
      throw Exception(_friendlyDioMessage(e, fallback: 'Login failed'));
    }
  }

  @override
  Future<(TokensModel, UserModel)> register(String email, String password, {String? name}) async {
    try {
      final body = <String, dynamic>{'email': email, 'password': password};
      if (name != null) body['name'] = name;

      final res = await _dio.post(
        '$_baseUrl/auth/register',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
      );

      final data = _asMap(res.data);
      final tokens = _tokensFromResponse(data);

      final user = data['user'] is Map<String, dynamic>
          ? UserModel.fromJson(_asMap(data['user']))
          : await me(tokens.accessToken);

      return (tokens, user);
    } on DioException catch (e) {
      throw Exception(_friendlyDioMessage(e, fallback: 'Registration failed'));
    }
  }

  @override
  Future<String> refresh(String refreshToken) async {
    try {
      final res = await _dio.post(
        '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
      );
      final data = _asMap(res.data);
      // Support both { accessToken } and { tokens: { accessToken } }
      if (data['accessToken'] is String) return data['accessToken'] as String;
      if (data['tokens'] is Map) return _asMap(data['tokens'])['accessToken'] as String;
      throw Exception('Malformed refresh response');
    } on DioException catch (e) {
      throw Exception(_friendlyDioMessage(e, fallback: 'Token refresh failed'));
    }
  }

  @override
  Future<UserModel> me(String accessToken) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );
      return UserModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throw Exception(_friendlyDioMessage(e, fallback: 'Fetching profile failed'));
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        '$_baseUrl/auth/logout',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
      );
    } on DioException {
      // best-effort: ignore network/logical errors on logout
    }
  }

  // ---------- helpers ----------

  // Accept Map or any -> Map<String, dynamic>
  Map<String, dynamic> _asMap(dynamic v) =>
      (v as Map).cast<String, dynamic>();

  // Accept { tokens:{...} } OR flat { accessToken, refreshToken }
  TokensModel _tokensFromResponse(Map<String, dynamic> data) {
    if (data['tokens'] is Map) {
      return TokensModel.fromJson(_asMap(data['tokens']));
    }
    if (data['accessToken'] is String && data['refreshToken'] is String) {
      return TokensModel(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    }
    throw Exception('Malformed tokens in response');
  }

  String _friendlyDioMessage(DioException e, {required String fallback}) {
    final body = e.response?.data;
    if (body is Map && body['message'] is String) return body['message'] as String;
    if (e.message?.isNotEmpty == true) return e.message!;
    return fallback;
    // Optionally: inspect e.type for timeouts, etc., and customize further.
  }
}
