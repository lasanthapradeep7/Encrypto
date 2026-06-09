import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _biometricAuthentication = true;
  bool _cloudSync = false;

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: true,
          onBackPressed: widget.onBackPressed,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'User Profile',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _ProfileHero(),
                  const SizedBox(height: 28),
                  Text(
                    'Personal Information',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ProfileMenuGroup(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.manage_accounts_outlined,
                        label: 'Edit Profile',
                        onTap: () => _showComingSoon('Edit Profile'),
                      ),
                      _ProfileActionTile(
                        icon: Icons.password_rounded,
                        label: 'Change password',
                        onTap: () => _showComingSoon('Change password'),
                      ),
                      _ProfileSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric authentication',
                        value: _biometricAuthentication,
                        onChanged: (value) {
                          setState(() => _biometricAuthentication = value);
                        },
                      ),
                      _ProfileSwitchTile(
                        icon: Icons.cloud_sync_rounded,
                        label: 'Cloud sync',
                        value: _cloudSync,
                        onChanged: (value) {
                          setState(() => _cloudSync = value);
                        },
                      ),
                      _ProfileActionTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailingText: 'English',
                        onTap: () => _showComingSoon('Language'),
                      ),
                      _ProfileActionTile(
                        icon: Icons.group_add_outlined,
                        label: 'Invite Friends',
                        onTap: () => _showComingSoon('Invite Friends'),
                      ),
                      _ProfileActionTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () => _showComingSoon('Help Center'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accent,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.86),
                  width: 4,
                ),
                boxShadow: AppShadows.accentGlow,
              ),
              child: Text(
                'LP',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundStart,
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Lasantha Pradee',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'lasantha@example.com',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.46),
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.34)),
          ),
          child: Text(
            'Vault owner',
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return _ProfileTileShell(
      onTap: onTap,
      child: Row(
        children: [
          _TileIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(child: _TileLabel(label)),
          if (trailingText case final value?) ...[
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.48),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.56),
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitchTile extends StatelessWidget {
  const _ProfileSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ProfileTileShell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          _TileIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(child: _TileLabel(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: Colors.white.withValues(alpha: 0.82),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.16),
            trackOutlineColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTileShell extends StatelessWidget {
  const _ProfileTileShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 58),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          AppGradients.accentHorizontal.createShader(bounds),
      child: Icon(icon, size: 22),
    );
  }
}

class _TileLabel extends StatelessWidget {
  const _TileLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.92),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
