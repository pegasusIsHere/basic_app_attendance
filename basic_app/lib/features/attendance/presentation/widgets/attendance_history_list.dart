// lib/features/attendance/presentation/widgets/attendance_history_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_controller.dart';
import '../providers/attendance_state.dart';

class AttendanceHistoryList extends ConsumerWidget {
  const AttendanceHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    final history = switch (state) {
      AttendanceIdle(:final history) => history,
      AttendanceLoading(:final history) => history,
      AttendanceSuccess(:final history) => history,
      AttendanceError(:final history) => history,
      _ => const [],
    };

    if (history.isEmpty) {
      return const Text('No attendance yet');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final e = history[i];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(e.divisionName ?? e.divisionId),
          subtitle: Text('${e.status} • ${e.checkedAt.toLocal()}'),
          trailing: Text('${e.lat.toStringAsFixed(5)}, ${e.lng.toStringAsFixed(5)}'),
        );
      },
    );
  }
}
