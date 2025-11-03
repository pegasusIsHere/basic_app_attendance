import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'providers.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  String _log = 'Ready.';
  bool _busy = false;

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw Exception('Location permission denied.');
      }
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _createDemoUser() async {
    setState(() => _busy = true);
    try {
      final api = ref.read(attendanceApiProvider);
      final id = await api.createUser('Alice Demo');
      ref.read(userIdProvider.notifier).state = id;
      setState(() => _log = 'User created: $id');
    } catch (e) {
      setState(() => _log = 'Create user error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        setState(() => _log = 'No user. Create one first.');
        return;
      }
      final pos = await _getPosition();
      final api = ref.read(attendanceApiProvider);
      final r = await api.checkIn(
        userId: userId,
        lng: pos.longitude,
        lat: pos.latitude,
      );
      setState(() => _log = 'Checked in ✅\nDivision: ${r['divisionName']}\nAt: ${r['checkedAt']}');
    } catch (e) {
      setState(() => _log = 'Check-in error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('User: ${userId ?? "(none)"}')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _busy ? null : _createDemoUser,
                  child: const Text('Create Demo User'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _checkIn,
              icon: const Icon(Icons.location_pin),
              label: const Text("I'm here"),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
