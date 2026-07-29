import 'package:flutter/material.dart';
import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/core/theme/theme_controller.dart';
import 'package:encrypto/features/auth/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  runApp(const EncryptoApp());
}

class EncryptoApp extends StatefulWidget {
  const EncryptoApp({super.key});

  @override
  State<EncryptoApp> createState() => _EncryptoAppState();
}

class _EncryptoAppState extends State<EncryptoApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Authentication intentionally keeps its established visual design.
      // The signed-in shell applies the selected theme to its own subtree.
      darkTheme: AppTheme.light,
      themeMode: ThemeController.instance.mode,
      themeAnimationDuration: const Duration(milliseconds: 280),
      themeAnimationCurve: Curves.easeOutCubic,
      home: const SplashPage(),
    );
  }
}
