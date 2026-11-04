import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import 'report_model.dart';

class ReportRepository {
  ReportRepository(this._dio);

  final Dio _dio;

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
  }) async {
    return _submit(
      '/reports/$id',
      'PATCH',
      title: title,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      image: image,
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
  }) async {
    try {
      final data = FormData.fromMap({
        'title': title,
        'description': description,
        'location_address': address,
        'latitude': ?latitude,
        'longitude': ?longitude,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
      });
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
