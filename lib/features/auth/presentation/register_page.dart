import 'package:flutter/material.dart';

import 'auth_form_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const AuthFormPage(register: true);
}
