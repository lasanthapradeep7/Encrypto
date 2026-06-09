import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({
    super.key,
    required this.onOpenWorkflow,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          onProfilePressed: onOpenProfile,
          onNotificationsPressed: onOpenNotifications,
          onSettingsPressed: onOpenSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Page header
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) =>
                            AppGradients.accentHorizontal.createShader(b),
                        child: const Icon(Icons.shield_outlined, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security center',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Monitor keys, access & policies',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Status card
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) =>
                                  AppGradients.accentHorizontal.createShader(b),
                              child: const Icon(
                                Icons.health_and_safety_rounded,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Protection status',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SecurityStatusRow(
                          icon: Icons.fingerprint_rounded,
                          label: 'Biometric lock',
                          value: 'Enabled',
                          status: _StatusType.success,
                        ),
                        _StatusDivider(),
                        const _SecurityStatusRow(
                          icon: Icons.cloud_sync_rounded,
                          label: 'Cloud sync policy',
                          value: 'Manual',
                          status: _StatusType.warning,
                        ),
                        _StatusDivider(),
                        const _SecurityStatusRow(
                          icon: Icons.key_rounded,
                          label: 'Key rotation',
                          value: 'Scheduled',
                          status: _StatusType.info,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Actions card
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) =>
                                  AppGradients.accentHorizontal.createShader(b),
                              child: const Icon(Icons.bolt_rounded, size: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Actions',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SecurityActionTile(
                          label: 'Open encryption workflow',
                          subtitle: 'Lock or unlock your data',
                          icon: Icons.lock_rounded,
                          gradient: AppGradients.accentHorizontal,
                          onPressed: onOpenWorkflow,
                        ),
                        const SizedBox(height: 10),
                        const _SecurityActionTile(
                          label: 'Review trusted devices',
                          subtitle: 'Manage device access',
                          icon: Icons.devices_rounded,
                          gradient: LinearGradient(
                            colors: [Color(0xFF34D399), Color(0xFF059669)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status type enum for badge styling
// ---------------------------------------------------------------------------
enum _StatusType { success, warning, info }

class _StatusDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _SecurityStatusRow extends StatelessWidget {
  const _SecurityStatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  final IconData icon;
  final String label;
  final String value;
  final _StatusType status;

  Color get _badgeColor {
    return switch (status) {
      _StatusType.success => AppColors.success,
      _StatusType.warning => AppColors.warning,
      _StatusType.info => AppColors.accent,
    };
  }

  Color get _iconColor {
    return switch (status) {
      _StatusType.success => const Color(0xFF34D399),
      _StatusType.warning => const Color(0xFFFBBF24),
      _StatusType.info => const Color(0xFF60A5FA),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ),
        // Status badge pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _badgeColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _badgeColor.withValues(alpha: 0.40),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: textTheme.labelSmall?.copyWith(
                  color: _badgeColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityActionTile extends StatefulWidget {
  const _SecurityActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onPressed;

  @override
  State<_SecurityActionTile> createState() => _SecurityActionTileState();
}

class _SecurityActionTileState extends State<_SecurityActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: disabled
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _pressed
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: disabled
                      ? const LinearGradient(
                          colors: [Color(0x33FFFFFF), Color(0x22FFFFFF)],
                        )
                      : widget.gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: disabled
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: disabled
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: disabled ? 0.2 : 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
