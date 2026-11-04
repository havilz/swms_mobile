import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/ui/atoms/app_text_field.dart';
import 'map_picker_page.dart';
import 'report_form_controller.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  ReportFormController get controller => Get.find<ReportFormController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(controller.isEditing ? 'Edit laporan' : 'Buat laporan'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Ceritakan masalah yang Anda temukan.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: controller.titleController,
            label: 'Judul laporan',
            maxLength: 255,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul wajib diisi.';
              }
              if (value.trim().length > 255) {
                return 'Judul maksimal 255 karakter.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: controller.descriptionController,
            label: 'Deskripsi',
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Deskripsi wajib diisi.'
                : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: controller.addressController,
            label: 'Alamat lokasi',
            maxLength: 255,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alamat wajib diisi.';
              }
              if (value.trim().length > 255) {
                return 'Alamat maksimal 255 karakter.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isLocating.value
                        ? null
                        : controller.locateMe,
                    icon: controller.isLocating.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Gunakan GPS'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Pilih di peta'),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final lat = controller.latitude.value;
            final lng = controller.longitude.value;
            return lat == null || lng == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Koordinat: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
          }),
          const SizedBox(height: 24),
          Text(
            'Foto pendukung (opsional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG, atau WEBP · Maksimal 5 MB',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final file = controller.image.value;
            if (file == null) {
              return OutlinedButton.icon(
                onPressed: controller.chooseImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Pilih foto'),
              );
            }
            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureBuilder(
                    future: file.readAsBytes(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? Image.memory(
                            snapshot.data!,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(
                            width: 76,
                            height: 76,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus foto',
                  onPressed: () => controller.image.value = null,
                  icon: const Icon(Icons.close),
                ),
              ],
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final error = controller.errorMessage.value;
            return error == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      error,
                      style: const TextStyle(color: Color(0xFFB42318)),
                    ),
                  );
          }),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmitting.value ? null : _submit,
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      controller.isEditing
                          ? 'Simpan perubahan'
                          : 'Kirim laporan',
                    ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _openMap() async {
    final coordinate =
        controller.latitude.value != null && controller.longitude.value != null
        ? LatLng(controller.latitude.value!, controller.longitude.value!)
        : null;
    final selected = await Get.to<LatLng>(
      () => const MapPickerPage(),
      arguments: coordinate,
    );
    if (selected == null) return;
    await controller.setLocation(selected.latitude, selected.longitude);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await controller.submit();
    if (success) {
      Get.back();
      Get.snackbar('Laporan terkirim', 'Laporan Anda berhasil dikirim.');
    }
  }
}
