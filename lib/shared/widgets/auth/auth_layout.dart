import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -70,
            child: _AuraCircle(
              size: 220,
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: _AuraCircle(
              size: 260,
              color: Colors.cyan.withValues(alpha: 0.12),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AuthPanel extends StatelessWidget {
  const AuthPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }
}

class AuthTitleBlock extends StatelessWidget {
  const AuthTitleBlock({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });

  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.hint,
    required this.prefix,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
  });

  final String hint;
  final IconData prefix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefix, color: AppColors.textSecondary),
        suffixIcon: suffix,
      ),
    );
  }
}

class _AuraCircle extends StatelessWidget {
  const _AuraCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
