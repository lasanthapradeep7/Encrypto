import 'package:flutter/material.dart';
import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const EncryptoApp());
}

class EncryptoApp extends StatelessWidget {
  const EncryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
