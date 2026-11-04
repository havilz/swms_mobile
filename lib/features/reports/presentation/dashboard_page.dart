import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/ui/molecules/kpi_value.dart';
import '../../../shared/ui/molecules/report_list_tile.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardController get controller => Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = Get.find<AuthController>().user.value?.name
        .trim()
        .split(RegExp(r'\s+'))
        .first;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.recycling, color: AppTheme.accent, size: 23),
            const SizedBox(width: 8),
            Text('SWMS', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Get.toNamed('/profile'),
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentSoft,
              child: Icon(
                Icons.person_outline,
                color: AppTheme.accentInk,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
            children: [
              Text(
                name == null || name.isEmpty ? 'Laporan saya' : 'Halo, $name',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 5),
              Text(
                'Pantau perkembangan laporan lingkungan Anda.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Temukan titik masalah. Laporkan dengan lokasi dan foto.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.accentInk, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Obx(
                () => _KpiGrid(
                  all: controller.counts['all'],
                  pending: controller.counts['pending'],
                  inProgress: controller.counts['in_progress'],
                  completed: controller.counts['completed'],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Riwayat laporan',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: Obx(
                  () => ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatusFilter(
                        label: 'Semua',
                        selected: controller.selectedStatus.value == null,
                        onTap: () => controller.selectStatus(null),
                      ),
                      _StatusFilter(
                        label: 'Menunggu',
                        selected: controller.selectedStatus.value == 'pending',
                        onTap: () => controller.selectStatus('pending'),
                      ),
                      _StatusFilter(
                        label: 'Ditangani',
                        selected:
                            controller.selectedStatus.value == 'in_progress',
                        onTap: () => controller.selectStatus('in_progress'),
                      ),
                      _StatusFilter(
                        label: 'Selesai',
                        selected:
                            controller.selectedStatus.value == 'completed',
                        onTap: () => controller.selectStatus('completed'),
                      ),
                      _StatusFilter(
                        label: 'Ditolak',
                        selected: controller.selectedStatus.value == 'rejected',
                        onTap: () => controller.selectStatus('rejected'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Obx(() {
                if (controller.errorMessage.value case final error?) {
                  return _DashboardMessage(
                    message: error,
                    actionLabel: 'Coba lagi',
                    onPressed: controller.refreshDashboard,
                  );
                }
                if (controller.isLoading.value && controller.reports.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.reports.isEmpty) {
                  return _DashboardMessage(
                    message:
                        'Belum ada laporan${controller.selectedStatus.value == null ? '' : ' dengan status ini'}.',
                    actionLabel: controller.selectedStatus.value == null
                        ? 'Buat laporan pertama'
                        : null,
                    onPressed: () => Get.toNamed('/reports/new'),
                  );
                }
                return Column(
                  children: [
                    for (final report in controller.reports) ...[
                      ReportListTile(report: report),
                      const Divider(height: 1),
                    ],
                    if (controller.currentPage < controller.lastPage)
                      TextButton(
                        onPressed: () => controller.loadReports(),
                        child: const Text('Muat lebih banyak'),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/reports/new'),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat laporan'),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.all,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  final int? all;
  final int? pending;
  final int? inProgress;
  final int? completed;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiValue(label: 'Semua laporan', value: all),
            ),
            const _VerticalRule(),
            Expanded(
              child: KpiValue(label: 'Menunggu', value: pending),
            ),
          ],
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        Row(
          children: [
            Expanded(
              child: KpiValue(label: 'Ditangani', value: inProgress),
            ),
            const _VerticalRule(),
            Expanded(
              child: KpiValue(label: 'Selesai', value: completed),
            ),
          ],
        ),
      ],
    ),
  );
}

class _VerticalRule extends StatelessWidget {
  const _VerticalRule();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 46, color: AppTheme.border);
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? AppTheme.accentInk : AppTheme.muted,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.accentSoft,
      side: BorderSide(color: selected ? AppTheme.accentSoft : AppTheme.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
  );
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    child: Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppTheme.muted, height: 1.4),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onPressed, child: Text(actionLabel!)),
      ],
    ),
  );
}
