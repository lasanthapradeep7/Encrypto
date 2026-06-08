import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// EncryptionContentContainer
// ---------------------------------------------------------------------------
class EncryptionContentContainer extends StatelessWidget {
  const EncryptionContentContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 24),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EncryptionSurfaceCard — premium glassmorphism card
// ---------------------------------------------------------------------------
class EncryptionSurfaceCard extends StatelessWidget {
  const EncryptionSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// EncryptoTopBar — top bar with blurred background
// ---------------------------------------------------------------------------
class EncryptoTopBar extends StatelessWidget {
  const EncryptoTopBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              if (showBackButton)
                _TopActionIcon(
                  icon: Icons.keyboard_double_arrow_left_rounded,
                  tooltip: 'Go back',
                  onTap: onBackPressed,
                )
              else
                const SizedBox(width: 40),
              const SizedBox(width: 8),
              _BrandMark(),
              const SizedBox(width: 8),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => AppGradients.brand.createShader(b),
                child: const Text(
                  'Encrypto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              const _TopActionIcon(
                icon: Icons.person_outline_rounded,
                tooltip: 'Profile',
              ),
              const SizedBox(width: 6),
              const _TopActionIcon(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 6),
              const _TopActionIcon(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EncryptionBottomNavigationBar — frosted glass floating nav
// ---------------------------------------------------------------------------
class EncryptionBottomNavigationBar extends StatelessWidget {
  const EncryptionBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xF2F8F8F8),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BottomNavButton(
                    icon: Icons.layers_rounded,
                    label: 'Vault',
                    selected: currentIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -12),
                    child: _CenterNavButton(
                      selected: currentIndex == 1,
                      onTap: () => onItemSelected(1),
                    ),
                  ),
                ),
                Expanded(
                  child: _BottomNavButton(
                    icon: Icons.shield_outlined,
                    label: 'Security',
                    selected: currentIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: AppGradients.accent,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.shield_moon_rounded, color: Colors.white, size: 17),
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) =>
                          AppGradients.accentHorizontal.createShader(b),
                      child: Icon(icon, size: 22),
                    )
                  : Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.accentDark
                    : const Color(0xFF9CA3AF),
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: selected ? 16 : 0,
              height: 3,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: selected ? AppGradients.accentHorizontal : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  const _CenterNavButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          gradient: selected
              ? AppGradients.accentHorizontal
              : const LinearGradient(
                  colors: [Color(0xFFE8EDF8), Color(0xFFD4DCF0)],
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: selected ? AppShadows.navCenter : AppShadows.card,
        ),
        child: Icon(
          Icons.apps_rounded,
          color: selected ? Colors.white : AppColors.accentDark,
          size: 26,
        ),
      ),
    );
  }
}
