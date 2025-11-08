// lib/features/attendance/domain/entities/attendance_entry.dart
class AttendanceEntry {
  final String id;
  final String divisionId;
  final String? divisionName;
  final double lng;
  final double lat;
  final String status; // present | in | out
  final DateTime checkedAt;

  const AttendanceEntry({
    required this.id,
    required this.divisionId,
    this.divisionName,
    required this.lng,
    required this.lat,
    required this.status,
    required this.checkedAt,
  });
}
