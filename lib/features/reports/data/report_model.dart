class ReportModel {
  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.locationAddress,
    required this.status,
    this.userId,
    this.latitude,
    this.longitude,
    this.imagePath,
    this.adminNotes,
    this.createdAt,
  });

  final int id;
  final int? userId;
  final String title;
  final String description;
  final String locationAddress;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final String? adminNotes;
  final DateTime? createdAt;

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    id: _asInt(json['id']),
    userId: json['user_id'] == null ? null : _asInt(json['user_id']),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    locationAddress: json['location_address'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    latitude: _asDouble(json['latitude']),
    longitude: _asDouble(json['longitude']),
    imagePath: json['image_path'] as String?,
    adminNotes: json['admin_notes'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  static int _asInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static double? _asDouble(Object? value) =>
      value == null ? null : double.tryParse(value.toString());
}

class ReportPage {
  const ReportPage({
    required this.items,
    required this.total,
    required this.page,
    required this.lastPage,
  });

  final List<ReportModel> items;
  final int total;
  final int page;
  final int lastPage;

  factory ReportPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return ReportPage(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ReportModel.fromJson)
                .toList(growable: false)
          : const [],
      total: meta is Map ? ReportModel._asInt(meta['total']) : 0,
      page: meta is Map ? ReportModel._asInt(meta['current_page']) : 1,
      lastPage: meta is Map ? ReportModel._asInt(meta['last_page']) : 1,
    );
  }
}
