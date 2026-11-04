import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/reports/data/report_model.dart';
import '../atoms/status_badge.dart';
import '../../theme/app_theme.dart';

class ReportListTile extends StatelessWidget {
  const ReportListTile({required this.report, super.key});

  final ReportModel report;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => Get.toNamed('/reports/detail', arguments: report.id),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 5),
                Text(
                  report.locationAddress.isEmpty
                      ? 'Lokasi belum dicantumkan'
                      : report.locationAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: report.status),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppTheme.muted, size: 20),
        ],
      ),
    ),
  );
}
