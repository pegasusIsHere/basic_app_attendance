// lib/features/auth/presentation/pages/splash_page.dart
import 'package:basic_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // kick bootstrap once the widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    // The router should react to AuthState. For simplicity we render a basic UI here.
    return Scaffold(
      body: Center(
        child: switch (state) {
          AuthLoading() || AuthUnknown() => const CircularProgressIndicator(),
          AuthUnauthenticated() => const Text('Not authenticated'),
          AuthAuthenticated() => const Text('Authenticated'),
        },
      ),
    );
  }
}
