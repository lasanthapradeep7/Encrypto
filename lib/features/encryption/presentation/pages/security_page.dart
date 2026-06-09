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
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            AppGradients.accentHorizontal.createShader(bounds),
                        child: const Icon(Icons.shield_outlined, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intruder Alert',
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              'Review failed access attempts',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _RiskBadge(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  EncryptionSurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _AlertIcon(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3 attempts blocked',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  Text(
                                    'Last attempt detected 2 min ago',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.52,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _SectionTitle('Intruder Photos'),
                        const SizedBox(height: 12),
                        const _IntruderPhotoStrip(),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppGradients.accentHorizontal,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.accent,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: onOpenWorkflow,
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('More Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Failed Login Attempts'),
                  const SizedBox(height: 12),
                  const _LoginAttemptList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.34)),
      ),
      child: Text(
        'High risk',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: AppGradients.accentHorizontal,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.accent,
      ),
      child: const Icon(
        Icons.gpp_maybe_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _IntruderPhotoStrip extends StatelessWidget {
  const _IntruderPhotoStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          _IntruderPhotoCard(
            initials: 'A1',
            icon: Icons.face_retouching_natural_rounded,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF334155), Color(0xFF0F172A)],
            ),
            accent: AppColors.accent,
          ),
          SizedBox(width: 14),
          _IntruderPhotoCard(
            initials: 'A2',
            icon: Icons.face_4_rounded,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF312E81), Color(0xFF111827)],
            ),
            accent: Color(0xFFA78BFA),
          ),
        ],
      ),
    );
  }
}

class _IntruderPhotoCard extends StatelessWidget {
  const _IntruderPhotoCard({
    required this.initials,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  final String initials;
  final IconData icon;
  final Gradient gradient;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -16,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.48),
              size: 136,
            ),
          ),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withValues(alpha: 0.42)),
              ),
              child: Text(
                initials,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 12,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Captured',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginAttemptList extends StatelessWidget {
  const _LoginAttemptList();

  static const _attempts = [
    _LoginAttempt(date: 'Dec 23, 2025', time: '02:00 PM', method: 'PIN'),
    _LoginAttempt(date: 'Dec 23, 2025', time: '08:00 AM', method: 'Biometric'),
    _LoginAttempt(date: 'Dec 23, 2025', time: '08:00 AM', method: 'Biometric'),
    _LoginAttempt(date: 'Dec 02, 2025', time: '02:00 PM', method: 'PIN'),
    _LoginAttempt(date: 'Dec 02, 2025', time: '02:00 PM', method: 'PIN'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < _attempts.length; index++) ...[
          _LoginAttemptTile(attempt: _attempts[index]),
          if (index != _attempts.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LoginAttempt {
  const _LoginAttempt({
    required this.date,
    required this.time,
    required this.method,
  });

  final String date;
  final String time;
  final String method;
}

class _LoginAttemptTile extends StatelessWidget {
  const _LoginAttemptTile({required this.attempt});

  final _LoginAttempt attempt;

  Color get _methodColor {
    return attempt.method == 'PIN' ? AppColors.warning : AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _methodColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              attempt.method == 'PIN'
                  ? Icons.pin_outlined
                  : Icons.fingerprint_rounded,
              color: _methodColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  attempt.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attempt.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          _MethodBadge(label: attempt.method, color: _methodColor),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
