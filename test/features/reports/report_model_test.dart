import 'package:flutter_test/flutter_test.dart';
import 'package:swms_mobile/features/reports/data/report_model.dart';

void main() {
  test(
    'parses report coordinates returned as strings and pagination metadata',
    () {
      final page = ReportPage.fromJson({
        'data': [
          {
            'id': 42,
            'title': 'Sampah di taman',
            'description': 'Tumpukan sampah',
            'location_address': 'Taman kota',
            'latitude': '-6.2',
            'longitude': '106.8',
            'status': 'in_progress',
            'admin_notes': 'Sedang ditangani',
          },
        ],
        'meta': {'current_page': 2, 'last_page': 5, 'total': 42},
      });

      expect(page.total, 42);
      expect(page.page, 2);
      expect(page.lastPage, 5);
      expect(page.items.single.latitude, -6.2);
      expect(page.items.single.longitude, 106.8);
      expect(page.items.single.adminNotes, 'Sedang ditangani');
    },
  );

  test('prefers image_url and falls back to image_path', () {
    final imageUrl = ReportModel.fromJson({
      'id': 1,
      'image_url': 'https://cdn.example.test/new.jpg',
      'image_path': 'https://cdn.example.test/legacy.jpg',
    });
    final legacyImage = ReportModel.fromJson({
      'id': 2,
      'image_path': 'https://cdn.example.test/legacy.jpg',
    });

    expect(imageUrl.imagePath, 'https://cdn.example.test/new.jpg');
    expect(legacyImage.imagePath, 'https://cdn.example.test/legacy.jpg');
  });
}
