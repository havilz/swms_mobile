import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._tokenStorage);

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final user = Rxn<UserModel>();
  final isRestoring = true.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final registrationMayHaveSucceeded = false.obs;

  @override
  void onInit() {
    super.onInit();
    restoreSession();
  }

  Future<void> restoreSession() async {
    try {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        user.value = await _repository.currentUser();
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _tokenStorage.clear();
      } else {
        errorMessage.value = error.message;
      }
    } finally {
      isRestoring.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    registrationMayHaveSucceeded.value = false;
    return _authenticate(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    registrationMayHaveSucceeded.value = false;
    return _authenticate(
      () => _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }

  Future<bool> _authenticate(
    Future<({UserModel user, String token})> Function() action,
  ) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final session = await action();
      await _tokenStorage.write(session.token);
      user.value = session.user;
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      registrationMayHaveSucceeded.value = error.registrationMayHaveSucceeded;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> logout() async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      await _repository.logout();
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      Get.snackbar(
        'Sesi lokal dihapus',
        'Logout server gagal: ${error.message}',
      );
    } finally {
      await _tokenStorage.clear();
      user.value = null;
      isSubmitting.value = false;
      Get.offAllNamed('/onboarding');
    }
  }
}
