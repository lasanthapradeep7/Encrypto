import 'dart:async';

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';

import 'package:encrypto/features/auth/presentation/pages/login_page.dart';
import 'package:encrypto/shared/widgets/auth/auth_layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF72AEFF),
                          AppColors.accent,
                          AppColors.accentDark,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.45),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_moon_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Encrypto',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure files with confidence',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
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
