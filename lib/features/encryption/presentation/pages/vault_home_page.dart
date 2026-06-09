import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class VaultHomePage extends StatelessWidget {
  const VaultHomePage({
    super.key,
    required this.onOpenWorkflow,
    required this.onOpenSteganographyWorkflow,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenSteganographyWorkflow;
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
                        child: const Icon(Icons.layers_rounded, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Vault',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Manage protected files & sessions',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Summary card
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
                                Icons.bar_chart_rounded,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Vault summary',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SummaryRow(
                          icon: Icons.lock_rounded,
                          label: 'Encrypted files',
                          value: '24',
                          color: Color(0xFF60A5FA),
                        ),
                        _SummaryDivider(),
                        const _SummaryRow(
                          icon: Icons.cloud_done_rounded,
                          label: 'Cloud synced',
                          value: '18',
                          color: Color(0xFF34D399),
                        ),
                        _SummaryDivider(),
                        const _SummaryRow(
                          icon: Icons.verified_user_rounded,
                          label: 'Protected sessions',
                          value: '6',
                          color: Color(0xFFA78BFA),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Quick actions card
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
                              'Quick actions',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _VaultActionTile(
                          label: 'Start encryption workflow',
                          subtitle: 'Encrypt or decrypt your files',
                          icon: Icons.play_arrow_rounded,
                          gradient: AppGradients.accentHorizontal,
                          onPressed: onOpenWorkflow,
                        ),
                        const SizedBox(height: 10),
                        _VaultActionTile(
                          label: 'Open steganography',
                          subtitle: 'Hide data inside images',
                          icon: Icons.auto_awesome_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA78BFA), Color(0xFF7C3AFF)],
                          ),
                          onPressed: onOpenSteganographyWorkflow,
                        ),
                        const SizedBox(height: 10),
                        const _VaultActionTile(
                          label: 'Browse recent vault items',
                          subtitle: 'View your file history',
                          icon: Icons.folder_open_rounded,
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

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
          ).createShader(b),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultActionTile extends StatefulWidget {
  const _VaultActionTile({
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
  State<_VaultActionTile> createState() => _VaultActionTileState();
}

class _VaultActionTileState extends State<_VaultActionTile> {
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
              // Icon container with gradient
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
