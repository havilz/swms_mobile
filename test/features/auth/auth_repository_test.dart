import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swms_mobile/core/network/api_exception.dart';
import 'package:swms_mobile/features/auth/data/auth_repository.dart';

void main() {
  test('recovers a timed-out registration by logging in once', () async {
    final adapter = _RegistrationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final repository = AuthRepository(dio);

    final session = await repository.register(
      name: 'Rani',
      email: 'rani@example.test',
      phone: '',
      password: 'password123',
    );

    expect(adapter.paths, ['/auth/register', '/auth/login']);
    expect(session.token, 'verified-token');
    expect(session.user.name, 'Rani');
  });

  test(
    'explains an unconfirmed registration if recovery login also fails',
    () async {
      final adapter = _RegistrationAdapter(loginFails: true);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      final repository = AuthRepository(dio);

      await expectLater(
        repository.register(
          name: 'Rani',
          email: 'rani@example.test',
          phone: '',
          password: 'password123',
        ),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.registrationMayHaveSucceeded,
                'uncertain',
                true,
              )
              .having(
                (error) => error.message,
                'message',
                contains('Jangan daftar ulang'),
              ),
        ),
      );
      expect(adapter.paths, ['/auth/register', '/auth/login']);
    },
  );
}

class _RegistrationAdapter implements HttpClientAdapter {
  _RegistrationAdapter({this.loginFails = false});

  final bool loginFails;
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    if (options.path == '/auth/register') {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    if (loginFails) {
      return ResponseBody.fromString(
        jsonEncode({'message': 'Invalid credentials.'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'user': {
            'id': 42,
            'name': 'Rani',
            'email': 'rani@example.test',
            'phone': '',
          },
          'token': 'verified-token',
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
