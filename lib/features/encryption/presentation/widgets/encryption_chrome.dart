import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';

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
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
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
          const SizedBox(width: 6),
          _BrandMark(),
          const SizedBox(width: 8),
          const Text(
            'Encrypto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          const _TopActionIcon(icon: Icons.person_outline_rounded, tooltip: 'Profile'),
          const SizedBox(width: 6),
          const _TopActionIcon(icon: Icons.notifications_none_rounded, tooltip: 'Notifications'),
          const SizedBox(width: 6),
          const _TopActionIcon(icon: Icons.settings_outlined, tooltip: 'Settings'),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomNavButton(
                icon: Icons.layers_rounded,
                selected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: _CenterNavButton(
                  selected: currentIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
              ),
            ),
            Expanded(
              child: _BottomNavButton(
                icon: Icons.shield_outlined,
                selected: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB4C5EA), Color(0xFF63739A), Color(0xFF364666)],
        ),
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white, size: 19);
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
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: _TopIcon(icon: icon),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Center(
        child: Icon(
          icon,
          color: selected ? AppColors.accentDark : Colors.black,
          size: 24,
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
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6EAF2), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
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
