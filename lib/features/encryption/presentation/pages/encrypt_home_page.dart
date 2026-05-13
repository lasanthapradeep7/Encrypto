import 'package:flutter/material.dart';

import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class EncryptHomePage extends StatelessWidget {
  const EncryptHomePage({
    super.key,
    required this.onEncryptTap,
    required this.onDecryptTap,
    required this.onSteganographyTap,
  });

  final VoidCallback onEncryptTap;
  final VoidCallback onDecryptTap;
  final VoidCallback onSteganographyTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
      child: Column(
        children: [
          const EncryptoTopBar(),
          const Spacer(),
          const _HomeIllustration(),
          const SizedBox(height: 28),
          _HomeActionButton(label: 'Encrypt', onPressed: onEncryptTap),
          const SizedBox(height: 16),
          _HomeActionButton(label: 'Decrypt', onPressed: onDecryptTap),
          const SizedBox(height: 16),
          _HomeActionButton(
            label: 'Steganography',
            onPressed: onSteganographyTap,
          ),
          const SizedBox(height: 10),
          const Spacer(),
        ],
      ),
    );
  }
}

class _HomeIllustration extends StatelessWidget {
  const _HomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 58,
              top: 38,
              child: _GlowDot(
                size: 34,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            Positioned(
              right: 56,
              top: 42,
              child: _GlowDot(size: 10, color: Colors.white),
            ),
            Positioned(
              left: 52,
              bottom: 66,
              child: _GlowDot(size: 8, color: Colors.white),
            ),
            Positioned(left: 30, bottom: 84, child: _Sparkle()),
            Positioned(
              right: 42,
              bottom: 82,
              child: _GlowDot(
                size: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Positioned(
              bottom: 52,
              left: 42,
              child: Transform.rotate(
                angle: -0.42,
                child: Container(
                  width: 78,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 96,
              bottom: 46,
              child: Transform.rotate(
                angle: -0.18,
                child: Container(
                  width: 82,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 118,
              height: 142,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCAD3EA),
                    Color(0xFF7180A2),
                    Color(0xFF435274),
                  ],
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFF394662),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.auto_awesome, color: Colors.white, size: 20);
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
