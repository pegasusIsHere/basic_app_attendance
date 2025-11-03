class AttendanceModel {
  final String id;
  final String divisionId;
  final DateTime checkedAt;
  final String status;
  AttendanceModel({
    required this.id,
    required this.divisionId,
    required this.checkedAt,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> j) => AttendanceModel(
    id: j['attendanceId'] as String? ?? j['_id'] as String,
    divisionId: j['divisionId'] as String,
    checkedAt: DateTime.parse(j['checkedAt'] as String),
    status: j['status'] as String? ?? 'present',
  );
}
