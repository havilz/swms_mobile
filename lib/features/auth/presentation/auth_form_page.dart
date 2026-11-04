import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/ui/atoms/app_text_field.dart';
import 'auth_controller.dart';

class AuthFormPage extends StatefulWidget {
  const AuthFormPage({required this.register, super.key});

  final bool register;

  @override
  State<AuthFormPage> createState() => _AuthFormPageState();
}

class _AuthFormPageState extends State<AuthFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (!widget.register && Get.arguments is String) {
      _email.text = Get.arguments as String;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label wajib diisi.' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = widget.register
        ? await _auth.register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            password: _password.text,
          )
        : await _auth.login(_email.text.trim(), _password.text);
    if (success && mounted) {
      Get.offAllNamed('/home');
      if (widget.register) {
        Get.snackbar(
          'Akun siap digunakan',
          'Pendaftaran berhasil dan Anda sudah masuk.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.register ? 'Buat akun' : 'Masuk ke SWMS';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: const Text('SWMS'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.recycling,
                          color: AppTheme.accent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Laporan warga, tindak lanjut nyata',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppTheme.accentInk),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.register
                        ? 'Daftar sekali untuk mengirim dan memantau laporan.'
                        : 'Masuk untuk melihat kabar terbaru dari laporan Anda.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.muted, height: 1.45),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.register) ...[
                            AppTextField(
                              controller: _name,
                              label: 'Nama lengkap',
                              validator: (value) => _required(value, 'Nama'),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _phone,
                              label: 'Nomor telepon (opsional)',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                          ],
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (_required(value, 'Email') != null) {
                                return 'Email wajib diisi.';
                              }
                              if (!GetUtils.isEmail(value!.trim())) {
                                return 'Format email tidak valid.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _password,
                            label: 'Kata sandi',
                            obscureText: true,
                            validator: (value) {
                              if (_required(value, 'Kata sandi') != null) {
                                return 'Kata sandi wajib diisi.';
                              }
                              if (widget.register && value!.length < 8) {
                                return 'Kata sandi minimal 8 karakter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Obx(() {
                            final error = _auth.errorMessage.value;
                            if (error == null) return const SizedBox.shrink();
                            final uncertain =
                                widget.register &&
                                _auth.registrationMayHaveSucceeded.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: uncertain
                                    ? const Color(0xFFFFF8E7)
                                    : const Color(0xFFFFF0EE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: uncertain
                                      ? const Color(0xFFF2D28C)
                                      : const Color(0xFFF2C7C2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    error,
                                    style: TextStyle(
                                      color: uncertain
                                          ? const Color(0xFF805500)
                                          : const Color(0xFF8A2822),
                                    ),
                                  ),
                                  if (uncertain) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => Get.offNamed(
                                        '/login',
                                        arguments: _email.text.trim(),
                                      ),
                                      child: const Text(
                                        'Coba masuk dengan email ini',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          Obx(
                            () => ElevatedButton(
                              onPressed: _auth.isSubmitting.value
                                  ? null
                                  : _submit,
                              child: _auth.isSubmitting.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          widget.register
                                              ? 'Menyiapkan akun…'
                                              : 'Memeriksa akun…',
                                        ),
                                      ],
                                    )
                                  : Text(
                                      widget.register ? 'Buat akun' : 'Masuk',
                                    ),
                            ),
                          ),
                          if (widget.register) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Jika koneksi lambat, status akun akan kami periksa sebelum meminta Anda mencoba lagi.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.offNamed(
                        widget.register ? '/login' : '/register',
                        arguments: widget.register ? _email.text.trim() : null,
                      ),
                      child: Text(
                        widget.register
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
