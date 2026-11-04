import 'package:flutter/material.dart';

import 'auth_form_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const AuthFormPage(register: false);
}
