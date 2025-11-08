// lib/features/attendance/presentation/providers/attendance_controller.dart
import 'package:basic_app/core/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/attendance_entry.dart';
import '../../domain/usecases/check_in.dart';
import '../../domain/usecases/list_my_attendance.dart';
import 'attendance_state.dart';

// ——— Providers wiring (adjust imports to your actual shared providers) ———
import 'package:dio/dio.dart';
import '../../../../shared/providers/http_client_provider.dart';
import '../../../../core/network/endpoints.dart';
import '../../data/datasources/attendance_remote_ds.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';

final _attendanceRemoteProvider = Provider<AttendanceRemoteDS>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(baseUrlProvider);
  return AttendanceRemoteDSImpl(dio as Dio, baseUrl: baseUrl);
});

final _attendanceRepoProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(_attendanceRemoteProvider));
});

final _checkInUCProvider = Provider<CheckIn>((ref) => CheckIn(ref.watch(_attendanceRepoProvider)));
final _listMineUCProvider =
    Provider<ListMyAttendance>((ref) => ListMyAttendance(ref.watch(_attendanceRepoProvider)));

final locationServiceProvider = Provider<LocationService>((_) => LocationService());

final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  return AttendanceController(
    checkInUC: ref.watch(_checkInUCProvider),
    listMyUC: ref.watch(_listMineUCProvider),
    locator: ref.watch(locationServiceProvider),
  );
});

class AttendanceController extends StateNotifier<AttendanceState> {
  final CheckIn checkInUC;
  final ListMyAttendance listMyUC;
  final LocationService locator;

  AttendanceController({
    required this.checkInUC,
    required this.listMyUC,
    required this.locator,
  }) : super(const AttendanceIdle());

  Future<void> loadHistory() async {
    final hist = await listMyUC(limit: 20);
    state = AttendanceIdle(history: hist);
  }

  Future<void> checkIn({String status = 'present'}) async {
    final currentHistory =
        switch (state) { AttendanceIdle(:final history) || AttendanceLoading(:final history) || AttendanceSuccess(:final history) || AttendanceError(:final history) => history, _ => const <AttendanceEntry>[] };

    state = AttendanceLoading(currentHistory);
    try {
      final pos = await locator.current();
      final entry = await checkInUC(lng: pos.longitude, lat: pos.latitude, status: status);
      final hist = await listMyUC(limit: 20);
      state = AttendanceSuccess(entry, hist);
    } catch (e) {
      state = AttendanceError(e.toString(), currentHistory);
    }
  }
}
