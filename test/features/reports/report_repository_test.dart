import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swms_mobile/features/reports/data/report_repository.dart';
import 'package:swms_mobile/features/reports/presentation/report_image_provider.dart';

void main() {
  test('updates with multipart POST and PATCH method override', () async {
    final adapter = _ReportAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final repository = ReportRepository(
      dio,
      readToken: () async => 'test-token',
    );

    await repository.update(
      id: 42,
      title: 'Sampah baru',
      description: 'Deskripsi',
      address: 'Taman kota',
      image: XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'trash.jpg'),
    );

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/reports/42');
    expect(
      adapter.requests.single.contentType,
      contains('multipart/form-data'),
    );
    expect(adapter.requests.single.body, contains('name="_method"'));
    expect(adapter.requests.single.body, contains('PATCH'));
    expect(adapter.requests.single.body, contains('filename='));
    expect(adapter.requests.single.body, contains('name="image"'));
    expect(adapter.requests.single.body, contains('\x01\x02\x03'));
  });

  test('deletes the report using its API endpoint', () async {
    final adapter = _ReportAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final repository = ReportRepository(
      dio,
      readToken: () async => 'test-token',
    );

    await repository.delete(42);

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/reports/42');
  });

  test(
    'builds a streaming image request with auth and cache version',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1/'));
      final repository = ReportRepository(
        dio,
        readToken: () async => 'test-token',
      );

      final request = await repository.imageRequest(42, version: 123456);

      expect(
        request.uri.toString(),
        'https://api.example.test/api/v1/reports/42/image?v=123456',
      );
      expect(request.headers, {
        'Authorization': 'Bearer test-token',
        'Accept': 'image/*',
      });
    },
  );

  test('does not create an image request without an auth token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    final repository = ReportRepository(dio, readToken: () async => null);

    await expectLater(
      repository.imageRequest(42, version: 1),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'image cache key varies by auth token without printing the token',
    () async {
      final first = ReportImageProvider(
        'https://api.example.test/api/v1/reports/42/image?v=1',
        headers: {'Authorization': 'Bearer first-secret'},
      );
      final second = ReportImageProvider(
        'https://api.example.test/api/v1/reports/42/image?v=1',
        headers: {'Authorization': 'Bearer second-secret'},
      );

      final firstKey = await first.obtainKey(ImageConfiguration.empty);
      final secondKey = await second.obtainKey(ImageConfiguration.empty);

      expect(firstKey, isNot(secondKey));
      expect(firstKey.toString(), isNot(contains('first-secret')));
      expect(first.toString(), isNot(contains('first-secret')));
    },
  );
}

class _ReportAdapter implements HttpClientAdapter {
  final requests = <_CapturedRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final chunks = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        chunks.addAll(chunk);
      }
    }

    requests.add(
      _CapturedRequest(
        method: options.method,
        path: options.path,
        contentType:
            options.headers[Headers.contentTypeHeader]?.toString() ?? '',
        body: utf8.decode(chunks),
      ),
    );

    final response = options.method == 'DELETE'
        ? {'message': 'Laporan berhasil dihapus.'}
        : {
            'data': {
              'id': 42,
              'title': 'Sampah baru',
              'description': 'Deskripsi',
              'location_address': 'Taman kota',
              'status': 'pending',
            },
          };
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CapturedRequest {
  const _CapturedRequest({
    required this.method,
    required this.path,
    required this.contentType,
    required this.body,
  });

  final String method;
  final String path;
  final String contentType;
  final String body;
}
