import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swms_mobile/core/network/api_exception.dart';

void main() {
  test(
    'maps authorization and validation failures and retains field errors',
    () {
      final denied = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/reports/1'),
          response: Response(
            requestOptions: RequestOptions(path: '/reports/1'),
            statusCode: 403,
          ),
        ),
      );
      final invalid = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/reports'),
          response: Response(
            requestOptions: RequestOptions(path: '/reports'),
            statusCode: 422,
            data: {
              'errors': {
                'title': ['Judul wajib diisi.'],
              },
            },
          ),
        ),
      );

      expect(denied.message, contains('izin'));
      expect(invalid.message, contains('data'));
      expect(invalid.fieldErrors['title'], ['Judul wajib diisi.']);
    },
  );
}
