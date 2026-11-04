import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/app_theme.dart';
import 'auth_controller.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: Obx(() {
      final user = controller.user.value;
      if (user == null) {
        return const Center(child: Text('Informasi profil tidak tersedia.'));
      }
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.accentSoft,
            child: Text(
              user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
              style: const TextStyle(color: AppTheme.accentInk, fontSize: 24),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Center(
            child: Text(
              user.email,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 30),
          _ProfileField(label: 'Nama', value: user.name),
          _ProfileField(label: 'Email', value: user.email),
          _ProfileField(
            label: 'Telepon',
            value: user.phone?.isNotEmpty == true ? user.phone! : '—',
          ),
          const SizedBox(height: 20),
          Text(
            'Perubahan profil belum tersedia.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: controller.isSubmitting.value ? null : controller.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ],
      );
    }),
  );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
  );
}
