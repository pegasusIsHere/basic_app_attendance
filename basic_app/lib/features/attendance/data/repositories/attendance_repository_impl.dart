// lib/features/attendance/data/repositories/attendance_repository_impl.dart
import '../../domain/entities/attendance_entry.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_ds.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDS remote;
  AttendanceRepositoryImpl(this.remote);

  @override
  Future<AttendanceEntry> checkIn({required double lng, required double lat, String status = 'present'}) async {
    final json = await remote.checkIn(lng: lng, lat: lat, status: status);
    return AttendanceModel.fromCheckInJson(json);
  }

  @override
  Future<List<AttendanceEntry>> listMyAttendance({int limit = 20}) async {
    final list = await remote.listMyAttendance(limit: limit);
    return list.map((j) => AttendanceModel.fromHistoryJson(j)).toList();
  }
}
