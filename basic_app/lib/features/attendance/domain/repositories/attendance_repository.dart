// lib/features/attendance/domain/repositories/attendance_repository.dart
import '../entities/attendance_entry.dart';

abstract class AttendanceRepository {
  Future<AttendanceEntry> checkIn({
    required double lng,
    required double lat,
    String status = 'present',
  });

  Future<List<AttendanceEntry>> listMyAttendance({int limit = 20});
}
