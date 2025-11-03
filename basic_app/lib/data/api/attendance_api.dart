import 'package:dio/dio.dart';
import '../../core/http.dart';

class AttendanceApi {
  final Dio _dio = buildDio();

  Future<Map<String, dynamic>> health() async {
    final r = await _dio.get('/health');
    return r.data as Map<String, dynamic>;
  }

  Future<String> createUser(String name) async {
    final r = await _dio.post('/users', data: {'name': name});
    return (r.data as Map<String, dynamic>)['_id'] as String;
  }

  Future<Map<String, dynamic>> checkIn({
    required String userId,
    required double lng,
    required double lat,
  }) async {
    final r = await _dio.post('/attendance/check-in', data: {
      'userId': userId,
      'lng': lng,
      'lat': lat,
      'status': 'present',
    });
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> userAttendance(String userId) async {
    final r = await _dio.get('/users/$userId/attendance');
    return (r.data as List).cast<Map<String, dynamic>>();
  }
}
