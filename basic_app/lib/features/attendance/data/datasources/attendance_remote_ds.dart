// lib/features/attendance/data/datasources/attendance_remote_ds.dart
import 'package:dio/dio.dart';

abstract class AttendanceRemoteDS {
  Future<Map<String, dynamic>> checkIn({required double lng, required double lat, String status});
  Future<List<Map<String, dynamic>>> listMyAttendance({int limit});
}

class AttendanceRemoteDSImpl implements AttendanceRemoteDS {
  final Dio _dio;
  final String _baseUrl;
  AttendanceRemoteDSImpl(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  @override
  Future<Map<String, dynamic>> checkIn({required double lng, required double lat, String status = 'present'}) async {
    final res = await _dio.post('$_baseUrl/attendance/check-in', data: {
      'lng': lng,
      'lat': lat,
      'status': status,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listMyAttendance({int limit = 20}) async {
    final res = await _dio.get('$_baseUrl/attendance/me', queryParameters: {'limit': limit});
    final data = res.data as List;
    return data.cast<Map<String, dynamic>>();
  }
}
