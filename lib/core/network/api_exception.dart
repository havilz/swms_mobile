import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.registrationMayHaveSucceeded = false,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;
  final bool registrationMayHaveSucceeded;

  factory ApiException.fromDio(DioException exception) {
    final response = exception.response;
    final body = response?.data;
    final fieldErrors = <String, List<String>>{};
    var message =
        'Tidak dapat terhubung ke server. Periksa jaringan lalu coba lagi.';

    if (body is Map) {
      final serverMessage = body['message'];
      if (serverMessage is String && serverMessage.trim().isNotEmpty) {
        message = serverMessage;
      }
      final rawErrors = body['errors'];
      if (rawErrors is Map) {
        for (final entry in rawErrors.entries) {
          final value = entry.value;
          if (value is List) {
            fieldErrors[entry.key.toString()] = value
                .whereType<String>()
                .toList(growable: false);
          }
        }
      }
    }

    final statusCode = response?.statusCode;
    if (statusCode == 401) {
      message = 'Sesi berakhir. Silakan masuk kembali.';
    } else if (statusCode == 403) {
      message = 'Anda tidak memiliki izin untuk melakukan tindakan ini.';
    } else if (statusCode == 404) {
      message = 'Fitur ini belum tersedia pada API server.';
    } else if (statusCode == 422 &&
        message.startsWith('Tidak dapat terhubung')) {
      message = 'Periksa kembali data yang Anda masukkan.';
    } else if (statusCode == 429) {
      message = 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    } else if (statusCode != null &&
        statusCode >= 500 &&
        message.startsWith('Tidak dapat terhubung')) {
      message = 'Server sedang bermasalah. Coba lagi beberapa saat.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  @override
  String toString() => message;
}
