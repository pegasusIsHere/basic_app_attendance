// lib/features/attendance/presentation/pages/attendance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_controller.dart';
import '../providers/attendance_state.dart';
import '../widgets/present_button.dart';
import '../widgets/attendance_history_list.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceControllerProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(attendanceControllerProvider, (prev, next) {
      if (next is AttendanceSuccess) {
        final name = next.entry.divisionName ?? next.entry.divisionId;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marked present in $name at ${next.entry.checkedAt.toLocal()}')),
        );
      } else if (next is AttendanceError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PresentButton(),
          SizedBox(height: 24),
          Text('Recent'),
          SizedBox(height: 8),
          AttendanceHistoryList(),
        ],
      ),
    );
  }
}
