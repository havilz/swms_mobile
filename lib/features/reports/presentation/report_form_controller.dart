import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../data/report_model.dart';
import '../data/report_repository.dart';
import 'dashboard_controller.dart';

class ReportFormController extends GetxController {
  ReportFormController(this._repository);

  final ReportRepository _repository;
  final _geocoding = Geocoding(locale: const Locale('id', 'ID'));
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final image = Rxn<XFile>();
  final latitude = RxnDouble();
  final longitude = RxnDouble();
  final isSubmitting = false.obs;
  final isLocating = false.obs;
  final errorMessage = RxnString();
  ReportModel? editing;

  bool get isEditing => editing != null;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is ReportModel) {
      editing = argument;
      titleController.text = argument.title;
      descriptionController.text = argument.description;
      addressController.text = argument.locationAddress;
      latitude.value = argument.latitude;
      longitude.value = argument.longitude;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> chooseImage() async {
    errorMessage.value = null;
    final selected = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (selected == null) return;
    final extension = selected.name.split('.').last.toLowerCase();
    if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      errorMessage.value = 'Format foto harus JPG, JPEG, PNG, atau WEBP.';
      return;
    }
    if (await selected.length() > 5 * 1024 * 1024) {
      errorMessage.value = 'Ukuran foto maksimal 5 MB.';
      return;
    }
    image.value = selected;
  }

  Future<void> locateMe() async {
    isLocating.value = true;
    errorMessage.value = null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception(
          'Aktifkan layanan lokasi atau masukkan alamat secara manual.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Izin lokasi ditolak. Anda masih dapat mengisi alamat manual.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi dinonaktifkan. Aktifkan di pengaturan perangkat.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address =
              [
                    place.street,
                    place.subLocality,
                    place.locality,
                    place.administrativeArea,
                  ]
                  .whereType<String>()
                  .where((part) => part.trim().isNotEmpty)
                  .join(', ');
          if (address.isNotEmpty) addressController.text = address;
        }
      } on Exception {
        errorMessage.value = 'Koordinat didapat, tetapi alamat otomatis gagal. Isi alamat manual.';
      }
    } on Exception catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> setLocation(double lat, double lng) async {
    latitude.value = lat;
    longitude.value = lng;
    try {
      final places = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (places.isNotEmpty) {
        final place = places.first;
        final address =
            [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                ]
                .whereType<String>()
                .where((part) => part.trim().isNotEmpty)
                .join(', ');
        if (address.isNotEmpty) addressController.text = address;
      }
    } on Exception {
      errorMessage.value =
          'Koordinat dipilih. Lengkapi alamat secara manual bila diperlukan.';
    }
  }

  Future<bool> submit() async {
    errorMessage.value = null;
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      errorMessage.value = 'Judul, deskripsi, dan alamat wajib diisi.';
      return false;
    }
    isSubmitting.value = true;
    try {
      if (isEditing) {
        await _repository.update(
          id: editing!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          address: addressController.text.trim(),
          latitude: latitude.value,
          longitude: longitude.value,
          image: image.value,
        );
      } else {
        await _repository.create(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          address: addressController.text.trim(),
          latitude: latitude.value,
          longitude: longitude.value,
          image: image.value,
        );
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
      }
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
