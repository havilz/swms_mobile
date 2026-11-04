import 'dart:typed_data';

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

  Future<Uint8List> image(int id) async {
    try {
      final response = await _dio.get<List<int>>(
        '/reports/$id/image',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('Foto laporan kosong.');
      }
      return Uint8List.fromList(bytes);
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
