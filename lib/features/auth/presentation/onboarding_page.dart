import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.recycling,
                      color: AppTheme.accent,
                      size: 25,
                    ),
                    const SizedBox(width: 8),
                    Text('SWMS', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAPORAN LINGKUNGAN',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentInk,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ReportStep(
                        icon: Icons.location_on_outlined,
                        title: 'Tandai lokasi',
                        subtitle: 'Gunakan GPS atau tulis alamat',
                      ),
                      const _StepRule(),
                      _ReportStep(
                        icon: Icons.photo_outlined,
                        title: 'Tambahkan bukti',
                        subtitle: 'Sertakan foto bila diperlukan',
                      ),
                      const _StepRule(),
                      _ReportStep(
                        icon: Icons.fact_check_outlined,
                        title: 'Pantau tindak lanjut',
                        subtitle: 'Lihat status dan catatan admin',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Satu laporan bisa jadi awal perubahan.',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 27, height: 1.16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Laporkan masalah lingkungan di sekitar Anda dan ikuti perkembangannya langsung dari aplikasi.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppTheme.muted, height: 1.5),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: const Text('Masuk'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text('Belum punya akun? Buat akun'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ReportStep extends StatelessWidget {
  const _ReportStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppTheme.accent, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.muted),
    ],
  );
}

class _StepRule extends StatelessWidget {
  const _StepRule();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 32, top: 13, bottom: 13),
    child: Divider(height: 1, color: Color(0xFFCEE2D8)),
  );
}
