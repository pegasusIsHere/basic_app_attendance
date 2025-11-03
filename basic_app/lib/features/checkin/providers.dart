import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/api/attendance_api.dart';

final attendanceApiProvider = Provider<AttendanceApi>((ref) => AttendanceApi());

// For demo: store a “current user id” in memory
final userIdProvider = StateProvider<String?>((ref) => null);
