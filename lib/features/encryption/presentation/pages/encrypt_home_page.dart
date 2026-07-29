import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class EncryptHomePage extends StatelessWidget {
  const EncryptHomePage({
    super.key,
    required this.onEncryptTap,
    required this.onDecryptTap,
    required this.onSteganographyTap,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final VoidCallback onEncryptTap;
  final VoidCallback onDecryptTap;
  final VoidCallback onSteganographyTap;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          onNotificationsPressed: onOpenNotifications,
          onSettingsPressed: onOpenSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            AppGradients.accentHorizontal.createShader(bounds),
                        child: Icon(Icons.apps_rounded, size: 22),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick actions',
                              style: textTheme.titleLarge?.copyWith(
                                color: context.encryptoColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              'Choose how you want to protect or recover files',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: context.encryptoColors.textPrimary
                                    .withValues(alpha: 0.58),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _PrimaryWorkflowCard(onPressed: onEncryptTap),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactWorkflowCard(
                          title: 'Decrypt',
                          subtitle: 'Restore protected files',
                          icon: Icons.lock_open_rounded,
                          color: AppColors.success,
                          onPressed: onDecryptTap,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _CompactWorkflowCard(
                          title: 'Stego',
                          subtitle: 'Hide data in images',
                          icon: Icons.auto_awesome_rounded,
                          color: AppColors.warning,
                          onPressed: onSteganographyTap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  EncryptionSurfaceCard(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: context.encryptoColors.textPrimary
                                  .withValues(alpha: 0.72),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Protection methods',
                              style: textTheme.titleMedium?.copyWith(
                                color: context.encryptoColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        _MethodRow(
                          label: 'Biometric lock',
                          icon: Icons.fingerprint_rounded,
                          color: Color(0xFF60A5FA),
                        ),
                        SizedBox(height: 10),
                        _MethodRow(
                          label: 'Password key',
                          icon: Icons.password_rounded,
                          color: Color(0xFFA78BFA),
                        ),
                        SizedBox(height: 10),
                        _MethodRow(
                          label: 'Generated secure key',
                          icon: Icons.key_rounded,
                          color: Color(0xFF34D399),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryWorkflowCard extends StatelessWidget {
  const _PrimaryWorkflowCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: encryptoCardGradient(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.20),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useCompactLayout = constraints.maxWidth < 330;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encrypt file',
                    style: textTheme.titleLarge?.copyWith(
                      color: context.encryptoColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Lock files with AI keys and optional hidden cover data.',
                    style: textTheme.bodySmall?.copyWith(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.62,
                      ),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    height: 38,
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.accentHorizontal,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: AppShadows.accent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (useCompactLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _SecureIllustration()),
                    SizedBox(height: 12),
                    copy,
                  ],
                );
              }

              return Row(
                children: [
                  _SecureIllustration(),
                  SizedBox(width: 16),
                  Expanded(child: copy),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompactWorkflowCard extends StatelessWidget {
  const _CompactWorkflowCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 136,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.30)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: context.encryptoColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.54,
                  ),
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecureIllustration extends StatelessWidget {
  const _SecureIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 126,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            left: 12,
            child: _GlowDot(
              size: 34,
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.38),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 18,
            child: _GlowDot(
              size: 20,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 8,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 58,
                height: 44,
                decoration: BoxDecoration(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.92,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Container(
            width: 82,
            height: 94,
            decoration: BoxDecoration(
              gradient: AppGradients.processing,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.accentGlow,
            ),
            child: Icon(Icons.shield_rounded, color: Colors.white, size: 44),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.82),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.86,
                ),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: color.withValues(alpha: 0.85),
            size: 18,
          ),
        ],
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
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 18),
        ],
      ),
    );
  }
}
