// lib/features/auth/presentation/pages/profile_page.dart
import 'package:basic_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    if (state is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('ID'), subtitle: Text(user.id)),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          if (user.name != null) ListTile(title: const Text('Name'), subtitle: Text(user.name!)),
          ListTile(title: const Text('Role'), subtitle: Text(user.role)),
        ],
      ),
    );
  }
}
