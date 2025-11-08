// lib/features/attendance/domain/usecases/check_in.dart
import '../entities/attendance_entry.dart';
import '../repositories/attendance_repository.dart';

class CheckIn {
  final AttendanceRepository repo;
  CheckIn(this.repo);

  Future<AttendanceEntry> call({required double lng, required double lat, String status = 'present'}) {
    return repo.checkIn(lng: lng, lat: lat, status: status);
  }
}
