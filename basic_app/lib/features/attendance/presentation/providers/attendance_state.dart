// lib/features/attendance/presentation/providers/attendance_state.dart
import '../../domain/entities/attendance_entry.dart';

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceIdle extends AttendanceState {
  final List<AttendanceEntry> history;
  const AttendanceIdle({this.history = const []});
}

class AttendanceLoading extends AttendanceState {
  final List<AttendanceEntry> history;
  const AttendanceLoading(this.history);
}

class AttendanceSuccess extends AttendanceState {
  final AttendanceEntry entry;
  final List<AttendanceEntry> history;
  const AttendanceSuccess(this.entry, this.history);
}

class AttendanceError extends AttendanceState {
  final String message;
  final List<AttendanceEntry> history;
  const AttendanceError(this.message, this.history);
}
