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
        constraints: BoxConstraints(maxWidth: 540),
        child: Padding(padding: padding, child: child),
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
        gradient: encryptoCardGradient(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.14),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: context.encryptoColors.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: Offset(0, 6),
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
    this.onNotificationsPressed,
    this.onSettingsPressed,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.04),
            border: Border(
              bottom: BorderSide(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.08,
                ),
                width: 0.5,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 10, 24, 12),
                child: Row(
                  children: [
                    if (showBackButton) ...[
                      _TopActionIcon(
                        icon: Icons.keyboard_double_arrow_left_rounded,
                        tooltip: 'Go back',
                        onTap: onBackPressed,
                      ),
                      SizedBox(width: 8),
                    ],
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) => AppGradients.brand.createShader(b),
                      child: Text(
                        'Encrypto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.encryptoColors.textPrimary,
                        ),
                      ),
                    ),
                    Spacer(),
                    _TopActionIcon(
                      icon: Icons.notifications_none_rounded,
                      tooltip: 'Notifications',
                      onTap: onNotificationsPressed,
                    ),
                    SizedBox(width: 6),
                    _TopActionIcon(
                      icon: Icons.settings_outlined,
                      tooltip: 'Settings',
                      onTap: onSettingsPressed,
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? Color(0xF2F8F8F8)
                  : context.encryptoColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : context.encryptoColors.border,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Color(0x28000000)
                      : context.encryptoColors.shadow,
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
                  child: _BottomNavButton(
                    icon: Icons.apps_rounded,
                    label: 'Encrypt',
                    selected: currentIndex == 1,
                    onTap: () => onItemSelected(1),
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
                Expanded(
                  child: _BottomNavButton(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    selected: currentIndex == 3,
                    onTap: () => onItemSelected(3),
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

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({required this.icon, required this.tooltip, this.onTap});

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
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.9),
            size: 18,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? Color(0xFF9CA3AF)
        : context.encryptoColors.textSecondary;
    final selectedColor = isDark ? AppColors.accentDark : Color(0xFF3D4FE0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration: Duration(milliseconds: 200),
              child: selected
                  ? ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) =>
                          AppGradients.accentHorizontal.createShader(b),
                      child: Icon(icon, size: 22),
                    )
                  : Icon(icon, color: inactiveColor, size: 22),
            ),
            SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? selectedColor : inactiveColor,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: selected ? 16 : 0,
              height: 3,
              margin: EdgeInsets.only(top: 3),
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
