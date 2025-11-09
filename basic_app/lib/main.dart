// lib/main.dart
import 'package:basic_app/features/attendance/presentation/pages/attendance_page.dart';
import 'package:basic_app/features/auth/presentation/pages/login_page.dart';
import 'package:basic_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/providers/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    // Trigger token validation + fetchMe once at startup
    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).bootstrap();
      if (mounted) setState(() => _bootstrapped = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Attendance',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: !_bootstrapped || authState is AuthLoading
          ? const _Splash()
          : authState is AuthAuthenticated
              ? const AttendancePage()  //CheckInPage()
              : const LoginPage(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
