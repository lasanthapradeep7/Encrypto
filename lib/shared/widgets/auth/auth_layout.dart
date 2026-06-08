import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// AuthBackground — full-screen gradient backdrop with animated aura orbs
// ---------------------------------------------------------------------------
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          // Top-right large aura
          Positioned(
            top: -120,
            right: -80,
            child: _AuraCircle(
              size: 280,
              color: AppColors.accent.withValues(alpha: 0.18),
              blurSigma: 40,
            ),
          ),
          // Bottom-left aura
          Positioned(
            bottom: -140,
            left: -100,
            child: _AuraCircle(
              size: 300,
              color: const Color(0xFF7C3AFF).withValues(alpha: 0.12),
              blurSigma: 50,
            ),
          ),
          // Smaller top-left accent orb
          Positioned(
            top: 60,
            left: -40,
            child: _AuraCircle(
              size: 120,
              color: AppColors.accent.withValues(alpha: 0.10),
              blurSigma: 30,
            ),
          ),
          // Dot grid pattern
          const Positioned.fill(child: _DotGrid()),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AuthPanel — premium frosted-glass bottom sheet panel
// ---------------------------------------------------------------------------
class AuthPanel extends StatelessWidget {
  const AuthPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(36)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.0,
                ),
                boxShadow: AppShadows.panel,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AuthTitleBlock — animated kicker + title + subtitle above the panel
// ---------------------------------------------------------------------------
class AuthTitleBlock extends StatelessWidget {
  const AuthTitleBlock({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    this.showBadge = true,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBadge) ...[
            _SecurityBadge(),
            const SizedBox(height: 14),
          ],
          Text(
            kicker.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.accent.withValues(alpha: 0.9),
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AuthInputField — input with animated focus border
// ---------------------------------------------------------------------------
class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.hint,
    required this.prefix,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.controller,
    this.onChanged,
  });

  final String hint;
  final IconData prefix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => (_isFocused
                    ? AppGradients.accentHorizontal
                    : const LinearGradient(
                        colors: [AppColors.textSecondary, AppColors.textSecondary],
                      ))
                .createShader(bounds),
            child: Icon(widget.prefix, size: 20),
          ),
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GradientButton — premium gradient elevated button
// ---------------------------------------------------------------------------
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? const LinearGradient(
                  colors: [Color(0xFFD4DCF0), Color(0xFFD4DCF0)],
                )
              : AppGradients.accentHorizontal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled ? [] : AppShadows.accent,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor:
                disabled ? AppColors.textSecondary : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.20),
            const Color(0xFF7C3AFF).withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) =>
                AppGradients.accentHorizontal.createShader(b),
            child: const Icon(Icons.shield_rounded, size: 13),
          ),
          const SizedBox(width: 5),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) =>
                AppGradients.accentHorizontal.createShader(b),
            child: Text(
              'Military-grade encryption',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraCircle extends StatelessWidget {
  const _AuraCircle({
    required this.size,
    required this.color,
    this.blurSigma = 30,
  });

  final double size;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _DotGridPainter()),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const radius = 1.2;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
