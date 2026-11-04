import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'user_model.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) => _requestSession('/auth/login', {
    'email': email,
    'password': password,
    'remember': true,
  });

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      return await _requestSession('/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
      });
    } on ApiException catch (error) {
      if (!_mayHaveCreatedAccount(error)) rethrow;

      try {
        return await login(email: email, password: password);
      } on ApiException {
        throw ApiException(
          message:
              'Pendaftaran belum dapat dikonfirmasi. Akun mungkin sudah dibuat. '
              'Jangan daftar ulang dulu; coba masuk dengan email ini.',
          statusCode: error.statusCode,
          fieldErrors: error.fieldErrors,
          registrationMayHaveSucceeded: true,
        );
      }
    }
  }

  Future<UserModel> currentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respons profil tidak valid.');
      }
      return UserModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  ({UserModel user, String token}) _sessionFrom(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic> ||
        data['token'] is! String) {
      throw const FormatException('Respons autentikasi tidak valid.');
    }
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  Future<({UserModel user, String token})> _requestSession(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return _sessionFrom(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  bool _mayHaveCreatedAccount(ApiException error) {
    final statusCode = error.statusCode;
    return statusCode == null || statusCode >= 500;
  }
}
