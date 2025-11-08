// lib/features/attendance/data/models/attendance_model.dart
import '../../domain/entities/attendance_entry.dart';

class AttendanceModel extends AttendanceEntry {
  const AttendanceModel({
    required super.id,
    required super.divisionId,
    super.divisionName,
    required super.lng,
    required super.lat,
    required super.status,
    required super.checkedAt,
  });

  factory AttendanceModel.fromCheckInJson(Map<String, dynamic> j) {
    // server payload from your checkIn: { ok, attendanceId, divisionId, divisionName, checkedAt, userId, ... }
    return AttendanceModel(
      id: j['attendanceId'] as String,
      divisionId: j['divisionId'] as String,
      divisionName: j['divisionName'] as String?,
      // if server doesn’t echo coord back, you can fill 0.0/0.0 or pass from request
      lng: (j['coord']?['coordinates']?[0] as num?)?.toDouble() ?? 0.0,
      lat: (j['coord']?['coordinates']?[1] as num?)?.toDouble() ?? 0.0,
      status: j['status'] as String? ?? 'present',
      checkedAt: DateTime.parse(j['checkedAt'] as String),
    );
  }

  factory AttendanceModel.fromHistoryJson(Map<String, dynamic> j) {
    // server list rows: { divisionId, coord:{coordinates:[lng,lat]}, status, checkedAt }
    return AttendanceModel(
      id: (j['_id'] ?? j['id']) as String,
      divisionId: j['divisionId'] as String,
      divisionName: j['divisionName'] as String?, // if backend adds it
      lng: (j['coord']?['coordinates']?[0] as num).toDouble(),
      lat: (j['coord']?['coordinates']?[1] as num).toDouble(),
      status: j['status'] as String? ?? 'present',
      checkedAt: DateTime.parse(j['checkedAt'] as String),
    );
  }
}
