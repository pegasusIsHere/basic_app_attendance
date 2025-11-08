// lib/features/attendance/presentation/widgets/present_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_controller.dart';
import '../providers/attendance_state.dart';

class PresentButton extends ConsumerWidget {
  const PresentButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    final loading = state is AttendanceLoading;
    return FilledButton.icon(
      onPressed: loading ? null : () => ref.read(attendanceControllerProvider.notifier).checkIn(),
      icon: const Icon(Icons.check_circle),
      label: Text(loading ? 'Marking…' : "I'm present"),
    );
  }
}
