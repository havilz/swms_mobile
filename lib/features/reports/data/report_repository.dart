import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import 'report_model.dart';

class ReportImageRequest {
  const ReportImageRequest({required this.uri, required this.headers});

  final Uri uri;
  final Map<String, String> headers;
}

class ReportRepository {
  ReportRepository(this._dio, {required this._readToken});

  final Dio _dio;
  final Future<String?> Function() _readToken;

  Future<ReportPage> list({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports',
        queryParameters: {'status': ?status, 'page': page, 'per_page': perPage},
      );
      return ReportPage.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ReportModel> detail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/reports/$id');
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respons detail laporan tidak valid.');
      }
      return ReportModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ReportImageRequest> imageRequest(
    int id, {
    required int version,
  }) async {
    final token = await _readToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        message: 'Sesi berakhir. Silakan masuk kembali.',
        statusCode: 401,
      );
    }

    final baseUrl = _dio.options.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$baseUrl/reports/$id/image')
        .replace(queryParameters: {'v': version.toString()});
    return ReportImageRequest(
      uri: uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'image/*'},
    );
  }

  Future<ReportModel> create({
    required String title,
    required String description,
    required String address,
    double? latitude,
    double? longitude,
    XFile? image,
  }) async {
    return _submit(
      '/reports',
      'POST',
      title: title,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      image: image,
    );
  }

  Future<ReportModel> update({
    required int id,
    required String title,
    required String description,
    required String address,
    double? latitude,
    double? longitude,
    XFile? image,
    bool removeImage = false,
  }) async {
    return _submit(
      '/reports/$id',
      'POST',
      title: title,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      image: image,
      methodOverride: 'PATCH',
      removeImage: removeImage,
    );
  }

  Future<ReportModel> _submit(
    String path,
    String method, {
    required String title,
    required String description,
    required String address,
    double? latitude,
    double? longitude,
    XFile? image,
    String? methodOverride,
    bool removeImage = false,
  }) async {
    try {
      final fields = <String, dynamic>{
        'title': title,
        'description': description,
        'location_address': address,
        'latitude': ?latitude,
        'longitude': ?longitude,
      };
      if (methodOverride != null) fields['_method'] = methodOverride;
      if (removeImage) fields['remove_image'] = true;
      if (image != null) {
        fields['image'] = MultipartFile.fromBytes(
          await image.readAsBytes(),
          filename: image.name,
        );
      }
      final data = FormData.fromMap(fields);
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(method: method),
      );
      final body = response.data;
      final reportData = body?['data'];
      if (reportData is! Map<String, dynamic>) {
        throw const FormatException('Respons laporan tidak valid.');
      }
      return ReportModel.fromJson(reportData);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/reports/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
