// lib/features/auth/data/datasources/auth_local_ds.dart
import 'dart:async';

/// Simple abstraction around secure storage so we can swap implementations in tests.
abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String access, required String refresh});
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key, String value) _write;
  final Future<void> Function(String key) _delete;

  static const _kAccess = 'auth.access';
  static const _kRefresh = 'auth.refresh';

  AuthLocalDataSourceImpl({
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String value) write,
    required Future<void> Function(String key) delete,
  })  : _read = read,
        _write = write,
        _delete = delete;

  @override
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _write(_kAccess, access);
    await _write(_kRefresh, refresh);
  }

  @override
  Future<String?> readAccessToken() => _read(_kAccess);

  @override
  Future<String?> readRefreshToken() => _read(_kRefresh);

  @override
  Future<void> clearTokens() async {
    await _delete(_kAccess);
    await _delete(_kRefresh);
  }
}
