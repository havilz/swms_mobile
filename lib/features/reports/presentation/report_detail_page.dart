import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/ui/atoms/status_badge.dart';
import '../data/report_model.dart';
import 'report_detail_controller.dart';
import 'report_image_provider.dart';

class ReportDetailPage extends GetView<ReportDetailController> {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail laporan')),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final report = controller.report.value;
      if (report == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value ?? 'Laporan tidak ditemukan.',
                ),
                TextButton(
                  onPressed: () => controller.load(Get.arguments),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              StatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.createdAt == null
                ? 'Tanggal tidak tersedia'
                : 'Dikirim ${_formatDate(report.createdAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _DetailSection(title: 'Detail laporan', body: report.description),
          _DetailSection(
            title: 'Lokasi',
            body: report.locationAddress.isEmpty
                ? 'Alamat tidak tersedia'
                : report.locationAddress,
          ),
          if (report.latitude != null && report.longitude != null)
            _DetailSection(
              title: 'Koordinat',
              body: '${report.latitude}, ${report.longitude}',
            ),
          _DetailSection(
            title: 'Catatan admin',
            body: report.adminNotes?.trim().isNotEmpty == true
                ? report.adminNotes!
                : 'Belum ada catatan dari admin.',
          ),
          if (report.imagePath != null && report.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Foto laporan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: FutureBuilder(
                future: controller.loadImage(report),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Foto laporan tidak dapat dimuat.'),
                      ),
                    );
                  }
                  final imageRequest = snapshot.data;
                  if (imageRequest == null) {
                    return const Center(
                      child: SizedBox(
                        width: 180,
                        child: LinearProgressIndicator(),
                      ),
                    );
                  }
                  return Image(
                    image: ReportImageProvider(
                      imageRequest.uri.toString(),
                      headers: imageRequest.headers,
                    ),
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 180,
                          child: LinearProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Foto laporan tidak dapat dimuat.'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (controller.errorMessage.value != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value!,
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await Get.toNamed(
                      '/reports/edit',
                      arguments: report,
                    );
                    if (updated is ReportModel) {
                      controller.updateReport(updated);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB42318),
                  ),
                  onPressed: controller.isDeleting.value
                      ? null
                      : () => _confirmDelete(context),
                  icon: controller.isDeleting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(
                    controller.isDeleting.value ? 'Menghapus...' : 'Hapus',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }),
  );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: const Text('Laporan dan foto yang terlampir akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.delete();
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppTheme.border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    ),
  );
}
