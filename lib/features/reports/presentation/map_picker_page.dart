import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/theme/app_theme.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    _selected = argument is LatLng ? argument : const LatLng(-6.2, 106.816666);
  }

  @override
  Widget build(BuildContext context) {
    final config = Get.find<AppConfig>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih titik lokasi'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: _selected),
            child: const Text('Pilih'),
          ),
        ],
      ),
      body: config.googleMapsApiKey.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Google Maps belum dikonfigurasi. Isi GOOGLE_MAPS_API_KEY pada .env dan batasi key untuk aplikasi ini. Anda tetap dapat menggunakan GPS atau alamat manual.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selected,
                zoom: 15,
              ),
              onTap: (point) => setState(() => _selected = point),
              markers: {
                Marker(
                  markerId: const MarkerId('report-location'),
                  position: _selected,
                ),
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              onCameraIdle: () {
                if (mounted) setState(() {});
              },
              onCameraMove: (position) => _selected = position.target,
            ),
      bottomNavigationBar: config.googleMapsApiKey.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                  onPressed: () => Get.back(result: _selected),
                  child: const Text('Gunakan titik ini'),
                ),
              ),
            ),
    );
  }
}
