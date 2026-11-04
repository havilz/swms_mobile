import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      'in_progress' => (
        'Sedang ditangani',
        const Color(0xFFFFF3D6),
        const Color(0xFF805500),
      ),
      'completed' => (
        'Selesai',
        const Color(0xFFE5F5E9),
        const Color(0xFF17633D),
      ),
      'rejected' => (
        'Ditolak',
        const Color(0xFFFFE9E6),
        const Color(0xFF8A2822),
      ),
      _ => ('Menunggu', AppTheme.accentSoft, AppTheme.accentInk),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
