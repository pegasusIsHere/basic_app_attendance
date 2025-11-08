// lib/features/attendance/domain/usecases/list_my_attendance.dart
import '../entities/attendance_entry.dart';
import '../repositories/attendance_repository.dart';

class ListMyAttendance {
  final AttendanceRepository repo;
  ListMyAttendance(this.repo);

  Future<List<AttendanceEntry>> call({int limit = 20}) => repo.listMyAttendance(limit: limit);
}
