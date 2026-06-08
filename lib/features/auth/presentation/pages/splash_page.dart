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
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Pulsing ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotsAnimation = CurvedAnimation(
      parent: _dotsController,
      curve: Curves.linear,
    );

    // Navigate after delay
    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
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
                  // Logo with pulsing ring
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (_, __) => Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.22),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Inner pulse ring
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (_, __) => Transform.scale(
                              scale:
                                  1.0 + (_pulseAnimation.value - 1.0) * 0.5,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent
                                      .withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                          ),
                          // Logo container
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: AppGradients.accent,
                              boxShadow: AppShadows.accentGlow,
                            ),
                            child: const Icon(
                              Icons.shield_moon_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  // App name
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        AppGradients.accent.createShader(bounds),
                    child: Text(
                      'Encrypto',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 46,
                        letterSpacing: -1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure files with confidence',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Animated dot loader
                  _AnimatedDotLoader(animation: _dotsAnimation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDotLoader extends StatelessWidget {
  const _AnimatedDotLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot has a delayed phase
            final phase = (animation.value - i * 0.22).clamp(0.0, 1.0);
            final bounce = (phase < 0.5 ? phase : 1.0 - phase) * 2.0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -8 * bounce),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(
                      alpha: 0.4 + 0.6 * bounce,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
