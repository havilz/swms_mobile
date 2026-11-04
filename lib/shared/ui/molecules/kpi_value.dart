import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class KpiValue extends StatelessWidget {
  const KpiValue({required this.label, required this.value, super.key});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontSize: 13, color: AppTheme.muted),
        ),
        const SizedBox(height: 7),
        Text(
          value?.toString() ?? '—',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}
